"""Unit tests for the scene_detector module.

Tests the multi-plan scene detection logic:
- 0 faces → WIDE_SHOT mode
- 1 face → TALENT mode
- 2+ faces → GROUP mode

Also tests temporal smoothing and mode transition logic.
"""

import time

from ai.scene_detector import (
    SceneDetector,
    SceneMode,
    SceneConfig,
    SceneResult,
)


class TestSceneMode:
    """Tests for the SceneMode enum."""

    def test_wide_shot_value(self):
        assert SceneMode.WIDE_SHOT.value == "wide_shot"

    def test_talent_value(self):
        assert SceneMode.TALENT.value == "talent"

    def test_group_value(self):
        assert SceneMode.GROUP.value == "group"

    def test_enum_has_three_modes(self):
        assert len(SceneMode) == 3


class TestSceneConfig:
    """Tests for the SceneConfig dataclass."""

    def test_default_config(self):
        config = SceneConfig()
        assert config.title == ""
        assert config.subtitle == ""
        assert config.logo_path == ""
        assert config.group_title == ""
        assert config.group_subtitle == ""

    def test_config_with_values(self):
        config = SceneConfig(
            title="Morning Show",
            subtitle="Live from Studio A",
            logo_path="/path/to/logo.png",
            group_title="Panel Discussion",
            group_subtitle="Expert Roundtable",
        )
        assert config.title == "Morning Show"
        assert config.subtitle == "Live from Studio A"
        assert config.logo_path == "/path/to/logo.png"
        assert config.group_title == "Panel Discussion"
        assert config.group_subtitle == "Expert Roundtable"


class TestSceneResult:
    """Tests for the SceneResult dataclass."""

    def test_default_result(self):
        result = SceneResult(mode=SceneMode.WIDE_SHOT, face_count=0)
        assert result.mode == SceneMode.WIDE_SHOT
        assert result.face_count == 0
        assert result.talents == []
        assert isinstance(result.config, SceneConfig)
        assert result.confidence == 1.0
        assert result.stable is True
        assert result.timestamp_ms == 0

    def test_result_with_talents(self):
        talents = [{"name": "John Doe", "role": "Host"}]
        result = SceneResult(
            mode=SceneMode.TALENT,
            face_count=1,
            talents=talents,
        )
        assert result.mode == SceneMode.TALENT
        assert result.face_count == 1
        assert len(result.talents) == 1
        assert result.talents[0]["name"] == "John Doe"


class TestSceneDetectorBasics:
    """Basic tests for SceneDetector initialization and configuration."""

    def test_default_initialization(self):
        detector = SceneDetector()
        assert detector.stability_frames == 5
        assert detector.hysteresis_frames == 3
        assert detector.current_mode == SceneMode.WIDE_SHOT
        assert detector.is_stable is False

    def test_custom_stability_frames(self):
        detector = SceneDetector(stability_frames=10)
        assert detector.stability_frames == 10

    def test_custom_hysteresis_frames(self):
        detector = SceneDetector(hysteresis_frames=5)
        assert detector.hysteresis_frames == 5

    def test_minimum_stability_frames(self):
        detector = SceneDetector(stability_frames=0)
        assert detector.stability_frames == 1  # Minimum is 1

    def test_minimum_hysteresis_frames(self):
        detector = SceneDetector(hysteresis_frames=-1)
        assert detector.hysteresis_frames == 0  # Minimum is 0

    def test_default_config(self):
        config = SceneConfig(title="Test Show")
        detector = SceneDetector(default_config=config)
        assert detector.default_config.title == "Test Show"

    def test_set_config(self):
        detector = SceneDetector()
        config = SceneConfig(title="New Show")
        detector.set_config(config)
        assert detector.default_config.title == "New Show"


class TestSceneDetectorFaceCount:
    """Tests for face count to scene mode mapping."""

    def test_zero_faces_wide_shot(self):
        detector = SceneDetector(stability_frames=1, hysteresis_frames=0)
        result = detector.process(face_count=0)
        assert result.mode == SceneMode.WIDE_SHOT
        assert result.face_count == 0

    def test_one_face_talent(self):
        detector = SceneDetector(stability_frames=1, hysteresis_frames=0)
        result = detector.process(face_count=1)
        assert result.mode == SceneMode.TALENT
        assert result.face_count == 1

    def test_two_faces_group(self):
        detector = SceneDetector(stability_frames=1, hysteresis_frames=0)
        result = detector.process(face_count=2)
        assert result.mode == SceneMode.GROUP
        assert result.face_count == 2

    def test_multiple_faces_group(self):
        detector = SceneDetector(stability_frames=1, hysteresis_frames=0)
        result = detector.process(face_count=5)
        assert result.mode == SceneMode.GROUP
        assert result.face_count == 5

    def test_many_faces_group(self):
        detector = SceneDetector(stability_frames=1, hysteresis_frames=0)
        result = detector.process(face_count=10)
        assert result.mode == SceneMode.GROUP
        assert result.face_count == 10


class TestSceneDetectorTemporalSmoothing:
    """Tests for temporal smoothing and mode stability."""

    def test_mode_requires_stability_frames(self):
        detector = SceneDetector(stability_frames=3, hysteresis_frames=0)

        # First detection should return WIDE_SHOT (initial mode)
        result = detector.process(face_count=1)
        assert result.mode == SceneMode.WIDE_SHOT  # Not yet stable
        assert result.stable is False

        # Second detection
        result = detector.process(face_count=1)
        assert result.mode == SceneMode.WIDE_SHOT  # Still not stable

        # Third detection - now stable
        result = detector.process(face_count=1)
        assert result.mode == SceneMode.TALENT
        assert result.stable is True

    def test_mode_consistency_required(self):
        detector = SceneDetector(stability_frames=3, hysteresis_frames=0)

        # Mixed detections should not trigger mode change
        detector.process(face_count=1)
        detector.process(face_count=0)  # Reset
        detector.process(face_count=1)
        detector.process(face_count=1)

        # Mode should still be unstable due to inconsistency
        assert detector.current_mode == SceneMode.WIDE_SHOT

    def test_stable_mode_persistence(self):
        detector = SceneDetector(stability_frames=1, hysteresis_frames=0)

        # Establish TALENT mode
        detector.process(face_count=1)
        result = detector.process(face_count=1)
        assert result.mode == SceneMode.TALENT

        # Continue with same face count
        for _ in range(5):
            result = detector.process(face_count=1)
            assert result.mode == SceneMode.TALENT
            assert result.stable is True

    def test_hysteresis_prevents_oscillation(self):
        detector = SceneDetector(stability_frames=2, hysteresis_frames=3)

        # Establish TALENT mode
        detector.process(face_count=1)
        detector.process(face_count=1)
        assert detector.current_mode == SceneMode.TALENT

        # Brief loss of face should not immediately revert to WIDE_SHOT
        detector.process(face_count=0)
        assert detector.current_mode == SceneMode.TALENT

        detector.process(face_count=0)
        assert detector.current_mode == SceneMode.TALENT

        # After hysteresis period, should transition
        for _ in range(3):
            detector.process(face_count=0)

        assert detector.current_mode == SceneMode.WIDE_SHOT


class TestSceneDetectorTransitions:
    """Tests for scene mode transitions."""

    def test_wide_shot_to_talent(self):
        detector = SceneDetector(stability_frames=1, hysteresis_frames=0)
        assert detector.current_mode == SceneMode.WIDE_SHOT

        result = detector.process(face_count=1)
        assert result.mode == SceneMode.TALENT

    def test_wide_shot_to_group(self):
        detector = SceneDetector(stability_frames=1, hysteresis_frames=0)
        assert detector.current_mode == SceneMode.WIDE_SHOT

        result = detector.process(face_count=2)
        assert result.mode == SceneMode.GROUP

    def test_talent_to_wide_shot(self):
        detector = SceneDetector(stability_frames=1, hysteresis_frames=0)

        # Establish TALENT mode
        detector.process(face_count=1)
        assert detector.current_mode == SceneMode.TALENT

        # Transition to WIDE_SHOT
        result = detector.process(face_count=0)
        assert result.mode == SceneMode.WIDE_SHOT

    def test_talent_to_group(self):
        detector = SceneDetector(stability_frames=1, hysteresis_frames=0)

        # Establish TALENT mode
        detector.process(face_count=1)
        assert detector.current_mode == SceneMode.TALENT

        # Transition to GROUP
        result = detector.process(face_count=2)
        assert result.mode == SceneMode.GROUP

    def test_group_to_talent(self):
        detector = SceneDetector(stability_frames=1, hysteresis_frames=0)

        # Establish GROUP mode
        detector.process(face_count=3)
        assert detector.current_mode == SceneMode.GROUP

        # Transition to TALENT
        result = detector.process(face_count=1)
        assert result.mode == SceneMode.TALENT

    def test_group_to_wide_shot(self):
        detector = SceneDetector(stability_frames=1, hysteresis_frames=0)

        # Establish GROUP mode
        detector.process(face_count=3)
        assert detector.current_mode == SceneMode.GROUP

        # Transition to WIDE_SHOT
        result = detector.process(face_count=0)
        assert result.mode == SceneMode.WIDE_SHOT


class TestSceneDetectorWithTalents:
    """Tests for scene detection with talent data."""

    def test_talents_passed_through(self):
        detector = SceneDetector(stability_frames=1, hysteresis_frames=0)
        talents = [
            {"name": "John Doe", "role": "Host"},
            {"name": "Jane Smith", "role": "Guest"},
        ]

        result = detector.process(face_count=2, talents=talents)
        assert result.mode == SceneMode.GROUP
        assert len(result.talents) == 2
        assert result.talents[0]["name"] == "John Doe"
        assert result.talents[1]["name"] == "Jane Smith"

    def test_single_talent_in_talent_mode(self):
        detector = SceneDetector(stability_frames=1, hysteresis_frames=0)
        talents = [{"name": "John Doe", "role": "Host"}]

        result = detector.process(face_count=1, talents=talents)
        assert result.mode == SceneMode.TALENT
        assert len(result.talents) == 1
        assert result.talents[0]["name"] == "John Doe"

    def test_empty_talents_in_wide_shot(self):
        detector = SceneDetector(stability_frames=1, hysteresis_frames=0)

        result = detector.process(face_count=0)
        assert result.mode == SceneMode.WIDE_SHOT
        assert result.talents == []


class TestSceneDetectorConfig:
    """Tests for scene configuration handling."""

    def test_custom_config_in_result(self):
        default_config = SceneConfig(title="Default Show")
        detector = SceneDetector(
            stability_frames=1,
            hysteresis_frames=0,
            default_config=default_config,
        )

        result = detector.process(face_count=0)
        assert result.config.title == "Default Show"

    def test_override_config_per_call(self):
        default_config = SceneConfig(title="Default Show")
        detector = SceneDetector(
            stability_frames=1,
            hysteresis_frames=0,
            default_config=default_config,
        )

        override_config = SceneConfig(title="Special Segment")
        result = detector.process(face_count=0, config=override_config)
        assert result.config.title == "Special Segment"


class TestSceneDetectorReset:
    """Tests for detector reset functionality."""

    def test_reset_clears_mode(self):
        detector = SceneDetector(stability_frames=1, hysteresis_frames=0)

        # Establish TALENT mode
        detector.process(face_count=1)
        assert detector.current_mode == SceneMode.TALENT

        # Reset
        detector.reset()
        assert detector.current_mode == SceneMode.WIDE_SHOT
        assert detector.is_stable is False

    def test_reset_allows_fresh_detection(self):
        detector = SceneDetector(stability_frames=1, hysteresis_frames=0)

        # Process some frames
        for _ in range(5):
            detector.process(face_count=2)
        assert detector.current_mode == SceneMode.GROUP

        # Reset and start fresh
        detector.reset()

        result = detector.process(face_count=1)
        assert result.mode == SceneMode.TALENT


class TestSceneDetectorTimestamp:
    """Tests for timestamp handling."""

    def test_result_has_timestamp(self):
        detector = SceneDetector(stability_frames=1, hysteresis_frames=0)

        before_ms = int(time.time() * 1000)
        result = detector.process(face_count=0)
        after_ms = int(time.time() * 1000)

        assert before_ms <= result.timestamp_ms <= after_ms


class TestSceneDetectorConfidence:
    """Tests for confidence score handling."""

    def test_stable_mode_has_high_confidence(self):
        detector = SceneDetector(stability_frames=1, hysteresis_frames=0)

        result = detector.process(face_count=1)
        assert result.stable is True
        assert result.confidence == 1.0

    def test_unstable_mode_has_lower_confidence(self):
        detector = SceneDetector(stability_frames=3, hysteresis_frames=0)

        # First detection is unstable
        result = detector.process(face_count=1)
        assert result.stable is False
        assert result.confidence == 0.5
