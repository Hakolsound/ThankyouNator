#!/bin/bash
# Create test notes in Firebase using curl
# Run with: bash create-test-notes.sh

DATABASE_URL="https://scrabble-6b9ff-default-rtdb.firebaseio.com"

# Simple base64 test image
TEST_IMAGE="iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAFUlEQVR42mP8z8BQz0AEYBxVSF+FABJADveWkH6oAAAAAElFTkSuQmCC"

echo "Creating test notes in Firebase..."
echo ""

# Test Note 1
SESSION_ID_1="test-$(date +%s)-1"
TIMESTAMP_1=$(($(date +%s) * 1000))
curl -X PUT "${DATABASE_URL}/sessions/${SESSION_ID_1}.json" \
  -H "Content-Type: application/json" \
  -d '{
    "sessionId": "'${SESSION_ID_1}'",
    "status": "ready_for_display",
    "createdAt": '${TIMESTAMP_1}',
    "expiresAt": '$(($TIMESTAMP_1 + 3600000))',
    "iPad_input": {
      "recipient": "Sarah Johnson",
      "sender": "Mike Chen",
      "drawingImage": "'${TEST_IMAGE}'",
      "templateTheme": "watercolor"
    }
  }'
echo "✅ Created note from Mike Chen to Sarah Johnson"
sleep 1

# Test Note 2
SESSION_ID_2="test-$(date +%s)-2"
TIMESTAMP_2=$(($(date +%s) * 1000))
curl -X PUT "${DATABASE_URL}/sessions/${SESSION_ID_2}.json" \
  -H "Content-Type: application/json" \
  -d '{
    "sessionId": "'${SESSION_ID_2}'",
    "status": "ready_for_display",
    "createdAt": '${TIMESTAMP_2}',
    "expiresAt": '$(($TIMESTAMP_2 + 3600000))',
    "iPad_input": {
      "recipient": "The Amazing Team",
      "sender": "Emily Rodriguez",
      "drawingImage": "'${TEST_IMAGE}'",
      "templateTheme": "heartBorder"
    }
  }'
echo "✅ Created note from Emily Rodriguez to The Amazing Team"
sleep 1

# Test Note 3
SESSION_ID_3="test-$(date +%s)-3"
TIMESTAMP_3=$(($(date +%s) * 1000))
curl -X PUT "${DATABASE_URL}/sessions/${SESSION_ID_3}.json" \
  -H "Content-Type: application/json" \
  -d '{
    "sessionId": "'${SESSION_ID_3}'",
    "status": "ready_for_display",
    "createdAt": '${TIMESTAMP_3}',
    "expiresAt": '$(($TIMESTAMP_3 + 3600000))',
    "iPad_input": {
      "recipient": "Dr. Smith",
      "sender": "John Williams",
      "drawingImage": "'${TEST_IMAGE}'",
      "templateTheme": "confetti"
    }
  }'
echo "✅ Created note from John Williams to Dr. Smith"
sleep 1

# Test Note 4
SESSION_ID_4="test-$(date +%s)-4"
TIMESTAMP_4=$(($(date +%s) * 1000))
curl -X PUT "${DATABASE_URL}/sessions/${SESSION_ID_4}.json" \
  -H "Content-Type: application/json" \
  -d '{
    "sessionId": "'${SESSION_ID_4}'",
    "status": "ready_for_display",
    "createdAt": '${TIMESTAMP_4}',
    "expiresAt": '$(($TIMESTAMP_4 + 3600000))',
    "iPad_input": {
      "recipient": "Mom & Dad",
      "sender": "Jennifer Lee",
      "drawingImage": "'${TEST_IMAGE}'",
      "templateTheme": "floral"
    }
  }'
echo "✅ Created note from Jennifer Lee to Mom & Dad"
sleep 1

# Test Note 5
SESSION_ID_5="test-$(date +%s)-5"
TIMESTAMP_5=$(($(date +%s) * 1000))
curl -X PUT "${DATABASE_URL}/sessions/${SESSION_ID_5}.json" \
  -H "Content-Type: application/json" \
  -d '{
    "sessionId": "'${SESSION_ID_5}'",
    "status": "ready_for_display",
    "createdAt": '${TIMESTAMP_5}',
    "expiresAt": '$(($TIMESTAMP_5 + 3600000))',
    "iPad_input": {
      "recipient": "Best Friend Emma",
      "sender": "Alex Thompson",
      "drawingImage": "'${TEST_IMAGE}'",
      "templateTheme": "stickyNote"
    }
  }'
echo "✅ Created note from Alex Thompson to Best Friend Emma"

echo ""
echo "🎉 All test notes created successfully!"
echo ""
echo "You should now see:"
echo "- 5 notes in the Host Panel dashboard"
echo "- Notes cycling on the Display (localhost:3000)"
echo "- Total counter showing '5 Thank You Notes'"
