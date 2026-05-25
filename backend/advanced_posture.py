import cv2
import mediapipe as mp
import math
import os

# ================= 1. 数学几何函数 =================
def calculate_tilt_angle(p1, p2):
    # 计算两点连线与水平基准线的夹角（高低肩倾斜度）
    delta_y = p2.y - p1.y
    delta_x = p2.x - p1.x
    angle_rad = math.atan2(delta_y, delta_x)
    return math.degrees(angle_rad)

# ================= 2. 初始化引擎 =================
IMAGE_PATH = 'test.png' # 依然使用你刚才成功的那张图
image = cv2.imread(IMAGE_PATH)
image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
h, w, _ = image.shape

mp_pose = mp.solutions.pose
mp_drawing = mp.solutions.drawing_utils
pose = mp_pose.Pose(static_image_mode=True, min_detection_confidence=0.3)

# ================= 3. 开始识别与测算 =================
results = pose.process(image_rgb)

if results.pose_landmarks:
    landmarks = results.pose_landmarks.landmark
    
    # 提取左肩(11)和右肩(12)的坐标
    l_shoulder = landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER]
    r_shoulder = landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER]
    
    # 转化为真实像素坐标
    l_x, l_y = int(l_shoulder.x * w), int(l_shoulder.y * h)
    r_x, r_y = int(r_shoulder.x * w), int(r_shoulder.y * h)
    
    # 调用数学公式计算倾角
    tilt_angle = abs(calculate_tilt_angle(l_shoulder, r_shoulder))
    
    # ================= 4. 图像渲染与输出 =================
    # 画基础骨架
    mp_drawing.draw_landmarks(
        image, results.pose_landmarks, mp_pose.POSE_CONNECTIONS,
        landmark_drawing_spec=mp_drawing.DrawingSpec(color=(0, 255, 0), thickness=3, circle_radius=2),
        connection_drawing_spec=mp_drawing.DrawingSpec(color=(200, 200, 200), thickness=2)
    )
    
    # 画高低肩专属的红色测量线
    cv2.line(image, (l_x, l_y), (r_x, r_y), (0, 0, 255), 4)
    
    # 将计算结果印在图片上
    status_text = f"Shoulder Tilt: {tilt_angle:.1f} deg"
    color = (0, 0, 255) if tilt_angle > 3.0 else (0, 255, 0) # 超过3度标红预警
    cv2.putText(image, status_text, (30, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, color, 2, cv2.LINE_AA)
    
    OUTPUT_PATH = 'advanced_output.jpg'
    cv2.imwrite(OUTPUT_PATH, image)
    print(f"✅ 计算完成！高低肩角度为: {tilt_angle:.1f}°，图已保存为 {OUTPUT_PATH}")
else:
    print("⚠️ 未识别到人体。")