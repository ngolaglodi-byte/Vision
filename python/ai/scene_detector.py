"""Multi-Plan Scene Detection for VisionCast-AI broadcast automation.

This module implements automatic scene mode detection based on face count:
- 0 faces → WIDE_SHOT mode (display title, logo, theme)
- 1 face → TALENT mode (display lower-third of recognized talent)
- 2+ faces → GROUP mode (display group overlay/panel)

The scene detector receives recognition results and determines the appropriate
broadcast scene mode with temporal smoothing to prevent rapid mode switching.
"""

import logging
import time
from dataclasses import dataclass, field
from enum import Enum
from typing import Any, Dict, List, Optional

logger = logging.getLogger(__name__)


class SceneMode(Enum):
    """Broadcast scene modes based on face detection count.

    WIDE_SHOT: No faces detected - show title, logo, theme
    TALENT: Single face detected - show lower-third overlay
    GROUP: Multiple faces detected - show group/panel overlay
    """
    WIDE_SHOT = "wide_shot"
    TALENT = "talent"
    GROUP = "group"


@dataclass
class SceneConfig:
    """Configuration for scene display options.

    Attributes:
        title: Show/segment title for WIDE_SHOT mode
        subtitle: Subtitle or theme for WIDE_SHOT mode
        logo_path: Path to logo image for WIDE_SHOT mode
        group_title: Title for GROUP mode overlay
        group_subtitle: Subtitle for GROUP mode overlay
    """
    title: str = ""
    subtitle: str = ""
    logo_path: str = ""
    group_title: str = ""
    group_subtitle: str = ""


@dataclass
class SceneResult:
    """Result of scene detection for a single frame.

    Attributes:
        mode: Detected scene mode (WIDE_SHOT, TALENT, or GROUP)
        face_count: Number of faces detected in the frame
        talents: List of recognized talent metadata (for TALENT/GROUP modes)
        config: Scene configuration for overlays
        confidence: Confidence score (0.0-1.0) for the detected mode
        stable: Whether the mode has been stable for enough frames
        timestamp_ms: Timestamp in milliseconds
    """
    mode: SceneMode
    face_count: int
    talents: List[Dict[str, Any]] = field(default_factory=list)
    config: SceneConfig = field(default_factory=SceneConfig)
    confidence: float = 1.0
    stable: bool = True
    timestamp_ms: int = 0


class SceneDetector:
    """Automatic scene mode detector based on face count.

    Implements temporal smoothing to prevent rapid mode switching during
    broadcast. The mode must be consistent for `stability_frames` consecutive
    frames before it is considered stable and reported.

    Args:
        stability_frames: Number of frames a mode must be consistent before
            being considered stable. Default is 5 frames (~166ms at 30fps).
        hysteresis_frames: Additional frames required to switch away from
            current mode, preventing oscillation. Default is 3 frames.
        default_config: Default scene configuration for overlays.

    Example:
        >>> detector = SceneDetector(stability_frames=5)
        >>> # Process recognition results
        >>> scene = detector.process(recognition_result)
        >>> if scene.mode == SceneMode.WIDE_SHOT:
        ...     show_title_overlay(scene.config.title)
        >>> elif scene.mode == SceneMode.TALENT:
        ...     show_lower_third(scene.talents[0])
        >>> elif scene.mode == SceneMode.GROUP:
        ...     show_group_overlay(scene.talents)
    """

    def __init__(
        self,
        stability_frames: int = 5,
        hysteresis_frames: int = 3,
        default_config: Optional[SceneConfig] = None,
    ):
        self.stability_frames = max(1, stability_frames)
        self.hysteresis_frames = max(0, hysteresis_frames)
        self.default_config = default_config or SceneConfig()

        self._current_mode: SceneMode = SceneMode.WIDE_SHOT
        self._pending_mode: Optional[SceneMode] = None
        self._mode_history: List[SceneMode] = []
        self._consecutive_count: int = 0
        self._last_result: Optional[SceneResult] = None

        logger.debug(
            "SceneDetector initialized: stability=%d, hysteresis=%d",
            self.stability_frames,
            self.hysteresis_frames,
        )

    def process(
        self,
        face_count: int,
        talents: Optional[List[Dict[str, Any]]] = None,
        config: Optional[SceneConfig] = None,
    ) -> SceneResult:
        """Process face detection result and determine scene mode.

        Args:
            face_count: Number of faces detected in the current frame.
            talents: List of recognized talent metadata dictionaries.
            config: Optional scene configuration override.

        Returns:
            SceneResult with the detected mode and metadata.
        """
        talents = talents or []
        config = config or self.default_config
        now_ms = int(time.time() * 1000)

        # Determine raw mode from face count
        raw_mode = self._face_count_to_mode(face_count)

        # Apply temporal smoothing
        stable, final_mode = self._apply_smoothing(raw_mode)

        # Build result
        result = SceneResult(
            mode=final_mode,
            face_count=face_count,
            talents=talents,
            config=config,
            confidence=1.0 if stable else 0.5,
            stable=stable,
            timestamp_ms=now_ms,
        )

        # Log mode transitions
        if self._last_result is None or self._last_result.mode != final_mode:
            logger.info(
                "Scene mode: %s (faces=%d, stable=%s)",
                final_mode.value,
                face_count,
                stable,
            )

        self._last_result = result
        return result

    def process_recognition_result(
        self,
        recognition_result: Any,
        config: Optional[SceneConfig] = None,
    ) -> SceneResult:
        """Process a RecognitionResult object from the recognition pipeline.

        This is a convenience method that extracts face count and talent
        information from a RecognitionResult object.

        Args:
            recognition_result: RecognitionResult from the recognition pipeline.
            config: Optional scene configuration override.

        Returns:
            SceneResult with the detected mode and metadata.
        """
        # Extract face count and talents from recognition result
        faces = getattr(recognition_result, 'faces', [])
        face_count = len(faces)

        talents = []
        for face in faces:
            if isinstance(face, dict):
                talent = face.get('talent')
            else:
                talent = getattr(face, 'talent', None)
            if talent:
                talents.append(talent)

        return self.process(face_count, talents, config)

    def reset(self) -> None:
        """Reset detector state to initial values."""
        self._current_mode = SceneMode.WIDE_SHOT
        self._pending_mode = None
        self._mode_history.clear()
        self._consecutive_count = 0
        self._last_result = None
        logger.debug("SceneDetector reset to initial state")

    def set_config(self, config: SceneConfig) -> None:
        """Update the default scene configuration.

        Args:
            config: New scene configuration for overlays.
        """
        self.default_config = config
        logger.debug("SceneDetector config updated: title=%s", config.title)

    @property
    def current_mode(self) -> SceneMode:
        """Get the current stable scene mode."""
        return self._current_mode

    @property
    def is_stable(self) -> bool:
        """Check if the current mode is stable."""
        return self._consecutive_count >= self.stability_frames

    def _face_count_to_mode(self, face_count: int) -> SceneMode:
        """Convert face count to scene mode.

        Args:
            face_count: Number of detected faces.

        Returns:
            SceneMode based on face count:
            - 0 faces → WIDE_SHOT
            - 1 face → TALENT
            - 2+ faces → GROUP
        """
        if face_count == 0:
            return SceneMode.WIDE_SHOT
        elif face_count == 1:
            return SceneMode.TALENT
        else:
            return SceneMode.GROUP

    def _apply_smoothing(self, raw_mode: SceneMode) -> tuple:
        """Apply temporal smoothing to prevent rapid mode switching.

        Returns:
            Tuple of (is_stable: bool, final_mode: SceneMode)
        """
        # Track mode history
        self._mode_history.append(raw_mode)
        if len(self._mode_history) > self.stability_frames + self.hysteresis_frames:
            self._mode_history.pop(0)

        # Check if we're transitioning to a new mode
        if raw_mode == self._current_mode:
            # Same mode, reset pending transition
            self._pending_mode = None
            self._consecutive_count = min(
                self._consecutive_count + 1,
                self.stability_frames + self.hysteresis_frames
            )
            return True, self._current_mode

        # Different mode detected
        if self._pending_mode == raw_mode:
            self._consecutive_count += 1
        else:
            self._pending_mode = raw_mode
            self._consecutive_count = 1

        # Check if pending mode is now stable
        required_frames = self.stability_frames
        if self._current_mode != SceneMode.WIDE_SHOT:
            # Add hysteresis when leaving TALENT or GROUP mode
            required_frames += self.hysteresis_frames

        if self._consecutive_count >= required_frames:
            # Transition to new mode
            old_mode = self._current_mode
            self._current_mode = raw_mode
            self._pending_mode = None
            logger.info(
                "Scene transition: %s → %s (after %d frames)",
                old_mode.value,
                raw_mode.value,
                self._consecutive_count,
            )
            return True, self._current_mode

        # Still transitioning, return current mode as unstable
        return False, self._current_mode
