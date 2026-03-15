"""Unit tests for the SceneChangeMessage in the IPC protocol.

Tests the scene change message serialization and deserialization
for multi-plan broadcast automation.
"""

import json
import sys
import os
import time

import pytest

# Ensure the python/ directory is importable.
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from ipc.protocol import SceneChangeMessage  # noqa: E402


class TestSceneChangeMessageBasics:
    """Basic tests for SceneChangeMessage initialization."""

    def test_default_initialization(self):
        msg = SceneChangeMessage(mode="wide_shot", face_count=0)
        assert msg.mode == "wide_shot"
        assert msg.face_count == 0
        assert msg.talents == []
        assert msg.title == ""
        assert msg.subtitle == ""
        assert msg.logo_path == ""
        assert msg.group_title == ""
        assert msg.group_subtitle == ""
        assert msg.confidence == 1.0
        assert msg.stable is True
        assert msg.timestamp_ms == 0

    def test_talent_mode_initialization(self):
        talents = [{"name": "John Doe", "role": "Host"}]
        msg = SceneChangeMessage(
            mode="talent",
            face_count=1,
            talents=talents,
            title="Morning Show",
        )
        assert msg.mode == "talent"
        assert msg.face_count == 1
        assert len(msg.talents) == 1
        assert msg.talents[0]["name"] == "John Doe"
        assert msg.title == "Morning Show"

    def test_group_mode_initialization(self):
        talents = [
            {"name": "John Doe", "role": "Host"},
            {"name": "Jane Smith", "role": "Guest"},
        ]
        msg = SceneChangeMessage(
            mode="group",
            face_count=2,
            talents=talents,
            group_title="Expert Panel",
            group_subtitle="Technology Discussion",
        )
        assert msg.mode == "group"
        assert msg.face_count == 2
        assert len(msg.talents) == 2
        assert msg.group_title == "Expert Panel"
        assert msg.group_subtitle == "Technology Discussion"


class TestSceneChangeMessageValidation:
    """Tests for SceneChangeMessage validation."""

    def test_valid_wide_shot_mode(self):
        msg = SceneChangeMessage(mode="wide_shot", face_count=0)
        assert msg.mode == "wide_shot"

    def test_valid_talent_mode(self):
        msg = SceneChangeMessage(mode="talent", face_count=1)
        assert msg.mode == "talent"

    def test_valid_group_mode(self):
        msg = SceneChangeMessage(mode="group", face_count=2)
        assert msg.mode == "group"

    def test_invalid_mode_raises(self):
        with pytest.raises(ValueError, match="Invalid mode"):
            SceneChangeMessage(mode="invalid_mode", face_count=0)

    def test_valid_modes_constant(self):
        assert SceneChangeMessage.VALID_MODES == ("wide_shot", "talent", "group")


class TestSceneChangeMessageSerialization:
    """Tests for SceneChangeMessage JSON serialization."""

    def test_to_json_wide_shot(self):
        msg = SceneChangeMessage(
            mode="wide_shot",
            face_count=0,
            title="VisionCast News",
            subtitle="Breaking News Coverage",
            logo_path="/logos/news.png",
        )
        json_str = msg.to_json()
        data = json.loads(json_str)

        assert data["type"] == "scene_change"
        assert data["mode"] == "wide_shot"
        assert data["face_count"] == 0
        assert data["title"] == "VisionCast News"
        assert data["subtitle"] == "Breaking News Coverage"
        assert data["logo_path"] == "/logos/news.png"

    def test_to_json_talent(self):
        talents = [{"name": "John Doe", "role": "Anchor"}]
        msg = SceneChangeMessage(
            mode="talent",
            face_count=1,
            talents=talents,
            confidence=0.95,
        )
        json_str = msg.to_json()
        data = json.loads(json_str)

        assert data["type"] == "scene_change"
        assert data["mode"] == "talent"
        assert data["face_count"] == 1
        assert len(data["talents"]) == 1
        assert data["talents"][0]["name"] == "John Doe"
        assert data["confidence"] == 0.95

    def test_to_json_group(self):
        talents = [
            {"name": "Host", "role": "Moderator"},
            {"name": "Guest 1", "role": "Expert"},
            {"name": "Guest 2", "role": "Analyst"},
        ]
        msg = SceneChangeMessage(
            mode="group",
            face_count=3,
            talents=talents,
            group_title="Panel Discussion",
            group_subtitle="AI in Broadcasting",
        )
        json_str = msg.to_json()
        data = json.loads(json_str)

        assert data["type"] == "scene_change"
        assert data["mode"] == "group"
        assert data["face_count"] == 3
        assert len(data["talents"]) == 3
        assert data["group_title"] == "Panel Discussion"
        assert data["group_subtitle"] == "AI in Broadcasting"

    def test_to_json_includes_timestamp(self):
        msg = SceneChangeMessage(mode="wide_shot", face_count=0)
        before_ms = int(time.time() * 1000)
        json_str = msg.to_json()
        after_ms = int(time.time() * 1000)

        data = json.loads(json_str)
        assert before_ms <= data["timestamp_ms"] <= after_ms

    def test_to_json_uses_provided_timestamp(self):
        msg = SceneChangeMessage(
            mode="wide_shot",
            face_count=0,
            timestamp_ms=1234567890,
        )
        json_str = msg.to_json()
        data = json.loads(json_str)

        assert data["timestamp_ms"] == 1234567890

    def test_to_json_stability_flag(self):
        msg_stable = SceneChangeMessage(mode="talent", face_count=1, stable=True)
        msg_unstable = SceneChangeMessage(mode="talent", face_count=1, stable=False)

        data_stable = json.loads(msg_stable.to_json())
        data_unstable = json.loads(msg_unstable.to_json())

        assert data_stable["stable"] is True
        assert data_unstable["stable"] is False


class TestSceneChangeMessageDeserialization:
    """Tests for SceneChangeMessage JSON deserialization."""

    def test_from_json_wide_shot(self):
        json_str = json.dumps({
            "type": "scene_change",
            "mode": "wide_shot",
            "face_count": 0,
            "talents": [],
            "title": "Morning News",
            "subtitle": "Live Coverage",
            "logo_path": "/logos/morning.png",
            "group_title": "",
            "group_subtitle": "",
            "confidence": 1.0,
            "stable": True,
            "timestamp_ms": 1000000,
        })
        msg = SceneChangeMessage.from_json(json_str)

        assert msg.mode == "wide_shot"
        assert msg.face_count == 0
        assert msg.title == "Morning News"
        assert msg.subtitle == "Live Coverage"
        assert msg.logo_path == "/logos/morning.png"
        assert msg.timestamp_ms == 1000000

    def test_from_json_talent(self):
        json_str = json.dumps({
            "type": "scene_change",
            "mode": "talent",
            "face_count": 1,
            "talents": [{"name": "Jane Smith", "role": "Reporter"}],
            "title": "",
            "subtitle": "",
            "logo_path": "",
            "group_title": "",
            "group_subtitle": "",
            "confidence": 0.92,
            "stable": True,
            "timestamp_ms": 2000000,
        })
        msg = SceneChangeMessage.from_json(json_str)

        assert msg.mode == "talent"
        assert msg.face_count == 1
        assert len(msg.talents) == 1
        assert msg.talents[0]["name"] == "Jane Smith"
        assert msg.confidence == 0.92

    def test_from_json_group(self):
        json_str = json.dumps({
            "type": "scene_change",
            "mode": "group",
            "face_count": 4,
            "talents": [
                {"name": "Host", "role": "Moderator"},
                {"name": "Guest A", "role": "Expert"},
                {"name": "Guest B", "role": "Analyst"},
                {"name": "Guest C", "role": "Correspondent"},
            ],
            "title": "",
            "subtitle": "",
            "logo_path": "",
            "group_title": "Round Table",
            "group_subtitle": "Weekly Discussion",
            "confidence": 1.0,
            "stable": True,
            "timestamp_ms": 3000000,
        })
        msg = SceneChangeMessage.from_json(json_str)

        assert msg.mode == "group"
        assert msg.face_count == 4
        assert len(msg.talents) == 4
        assert msg.group_title == "Round Table"
        assert msg.group_subtitle == "Weekly Discussion"

    def test_from_json_with_defaults(self):
        # Minimal JSON with required fields only
        json_str = json.dumps({
            "mode": "wide_shot",
            "face_count": 0,
        })
        msg = SceneChangeMessage.from_json(json_str)

        assert msg.mode == "wide_shot"
        assert msg.face_count == 0
        assert msg.talents == []
        assert msg.title == ""
        assert msg.confidence == 1.0
        assert msg.stable is True


class TestSceneChangeMessageRoundTrip:
    """Tests for SceneChangeMessage serialization/deserialization round-trip."""

    def test_round_trip_wide_shot(self):
        original = SceneChangeMessage(
            mode="wide_shot",
            face_count=0,
            title="Evening News",
            subtitle="Prime Time",
            logo_path="/logos/evening.png",
            timestamp_ms=5000000,
        )
        json_str = original.to_json()
        restored = SceneChangeMessage.from_json(json_str)

        assert restored.mode == original.mode
        assert restored.face_count == original.face_count
        assert restored.title == original.title
        assert restored.subtitle == original.subtitle
        assert restored.logo_path == original.logo_path
        assert restored.timestamp_ms == original.timestamp_ms

    def test_round_trip_talent(self):
        talents = [{"name": "John Doe", "role": "Anchor", "id": "t001"}]
        original = SceneChangeMessage(
            mode="talent",
            face_count=1,
            talents=talents,
            confidence=0.88,
            stable=True,
            timestamp_ms=6000000,
        )
        json_str = original.to_json()
        restored = SceneChangeMessage.from_json(json_str)

        assert restored.mode == original.mode
        assert restored.face_count == original.face_count
        assert restored.talents == original.talents
        assert restored.confidence == original.confidence
        assert restored.stable == original.stable

    def test_round_trip_group(self):
        talents = [
            {"name": "Host", "role": "Moderator"},
            {"name": "Expert 1", "role": "Analyst"},
            {"name": "Expert 2", "role": "Correspondent"},
        ]
        original = SceneChangeMessage(
            mode="group",
            face_count=3,
            talents=talents,
            group_title="Tech Talk",
            group_subtitle="AI Special",
            stable=False,
            confidence=0.75,
            timestamp_ms=7000000,
        )
        json_str = original.to_json()
        restored = SceneChangeMessage.from_json(json_str)

        assert restored.mode == original.mode
        assert restored.face_count == original.face_count
        assert restored.talents == original.talents
        assert restored.group_title == original.group_title
        assert restored.group_subtitle == original.group_subtitle
        assert restored.stable == original.stable
        assert restored.confidence == original.confidence
