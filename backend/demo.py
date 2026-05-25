import cv2
import mediapipe as mp
import os

print("--- 开始运行体态检测 ---")

# 1. 检查图片
IMAGE_PATH = 'test.png'
if not os.path.exists(IMAGE_PATH):
    print(f"❌ 严重错误：找不到 '{IMAGE_PATH}'！")
    exit()

# 2. 加载图像
print("✅ 找到图片，正在加载...")
image = cv2.imread(IMAGE_PATH)
image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

# 3. 初始化 MediaPipe
print("🤖 正在启动 MediaPipe 引擎...")
mp_pose = mp.solutions.pose
mp_drawing = mp.solutions.drawing_utils
pose = mp_pose.Pose(static_image_mode=True, min_detection_confidence=0.3)

# 4. 开始识别
results = pose.process(image_rgb)

# 5. 结果处理
if results.pose_landmarks:
    print("🎯 识别成功！提取到了 33 个关键点。")
    annotated_image = image.copy()
    
    mp_drawing.draw_landmarks(
        annotated_image, 
        results.pose_landmarks, 
        mp_pose.POSE_CONNECTIONS,
        landmark_drawing_spec=mp_drawing.DrawingSpec(color=(0, 255, 0), thickness=5, circle_radius=3),
        connection_drawing_spec=mp_drawing.DrawingSpec(color=(0, 0, 255), thickness=2)
    )
    
    cv2.imwrite('success_output.jpg', annotated_image)
    print("🎉 大功告成！快去左边文件夹看看生成的 success_output.jpg 吧！")
else:
    print("⚠️ 糟糕，模型没有在图片里找到人。")