from fastapi import FastAPI, File, UploadFile, Request
from fastapi.middleware.cors import CORSMiddleware
import cv2
import mediapipe as mp
import numpy as np
import math
import base64
from datetime import datetime
from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime
from sqlalchemy.orm import declarative_base, sessionmaker

# 🔥 新增：导入智谱大模型 SDK
from zhipuai import ZhipuAI

# ================= 1. 大模型配置 (AI 康复教练) =================
# 👇 把这里换成你在智谱官网申请到的 API Key
AI_CLIENT = ZhipuAI(api_key="ZHIPU") 

def get_ai_coach_advice(tilt_angle, diagnosis):
    """大模型提示词工程 (Prompt Engineering)"""
    prompt = f"""
    你现在是《塑影 Posture.AI》App 的首席骨科与运动康复专家。
    刚才有一位用户进行了体态检测，检测结果如下：
    - 高低肩倾斜角度：{tilt_angle}度
    - 系统初步诊断：{diagnosis}
    
    请你用温暖、专业的口吻，对这位用户说一段话。要求：
    1. 字数控制在 100 字以内，适合在手机屏幕上阅读。
    2. 如果角度大于3度，请给出一个具体的、能在办公室或宿舍立刻做的拉伸动作。
    3. 如果角度正常，请给予鼓励并提醒保持。
    """
    try:
        response = AI_CLIENT.chat.completions.create(
            model="glm-4-flash",  # 使用响应极快且免费的 flash 模型
            messages=[
                {"role": "system", "content": "你是一名专业的运动理疗师。"},
                {"role": "user", "content": prompt}
            ],
            temperature=0.7 # 控制回答的创造力，0.7 比较自然
        )
        return response.choices[0].message.content
    except Exception as e:
        return "AI 教练开小差了，请先注意保持正确的坐姿哦~"

# ================= 2. 数据库与基建 =================
SQLALCHEMY_DATABASE_URL = "sqlite:///./posture_data.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

class PostureRecord(Base):
    __tablename__ = "history_records"
    id = Column(Integer, primary_key=True, index=True)
    filename = Column(String)
    tilt_angle = Column(Float)
    diagnosis = Column(String)
    ai_advice = Column(String) # 🔥 数据库新增一列：用来存 AI 给出的话
    test_time = Column(DateTime, default=datetime.now)

Base.metadata.create_all(bind=engine)

# ================= 3. 初始化服务与引擎 =================
app = FastAPI(title="塑影 Posture.AI 终极云端接口", version="4.0 (AI 融合版)")
@app.get("/health")
def health_check():
    return {
        "status": "success",
        "message": "PostureAI backend is running"
    }
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])

mp_pose = mp.solutions.pose
mp_drawing = mp.solutions.drawing_utils
pose = mp_pose.Pose(static_image_mode=True, min_detection_confidence=0.3)

def calculate_tilt_angle(p1, p2):
    delta_y = abs(p2.y - p1.y)
    delta_x = abs(p2.x - p1.x)
    if delta_x == 0: return 90.0
    return math.degrees(math.atan(delta_y / delta_x))

# ================= 4. 核心 API (视觉 + LLM + 数据库) =================
@app.post("/analyze_image")
async def analyze_image(request: Request, file: UploadFile = File(None)):
    try:
        if file is not None:
            contents = await file.read()
            upload_filename =upload_filename
        else:
            body = await request.json()
            image_base64 = body.get("image_base64", "")
            upload_filename = body.get("filename", "posture_upload.jpg")

            if image_base64 == "":
                return {
                    "status": "error",
                    "message": "后端没有收到图片数据"
                }

            if "," in image_base64:
                image_base64 = image_base64.split(",", 1)[1]

            contents = base64.b64decode(image_base64)

       

        # --- 1. 视觉解析 ---

        nparr = np.frombuffer(contents, np.uint8)
        image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        if image is None: return {"status": "error", "message": "图片解析失败"}

        image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        results = pose.process(image_rgb)

        if results.pose_landmarks:
            landmarks = results.pose_landmarks.landmark
            l_shoulder = landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER]
            r_shoulder = landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER]
            tilt_angle = round(abs(calculate_tilt_angle(l_shoulder, r_shoulder)), 1)
            diagnosis = "发现高低肩风险" if tilt_angle > 3.0 else "肩部体态健康"
            
            # --- 2. 🔥 召唤大模型 (AI 康复教练) ---
            ai_advice = get_ai_coach_advice(tilt_angle, diagnosis)

            # --- 3. 存入数据库 ---
            db = SessionLocal()
            new_record = PostureRecord(
                filename=upload_filename, tilt_angle=tilt_angle, diagnosis=diagnosis, ai_advice=ai_advice
            )
            db.add(new_record)
            db.commit()
            db.close()

            # --- 4. 图像渲染与返回 ---
            annotated_image = image.copy()
            mp_drawing.draw_landmarks(
                annotated_image, results.pose_landmarks, mp_pose.POSE_CONNECTIONS,
                landmark_drawing_spec=mp_drawing.DrawingSpec(color=(0, 255, 0), thickness=3, circle_radius=2),
                connection_drawing_spec=mp_drawing.DrawingSpec(color=(0, 0, 255), thickness=2)
            )
            _, buffer = cv2.imencode('.jpg', annotated_image)
            
            return {
                "status": "success",
                "tilt_angle": tilt_angle,
                "diagnosis": diagnosis,
                "ai_coach": ai_advice, # 🔥 返回大模型的原话给前端
                "image_base64": base64.b64encode(buffer).decode('utf-8')
            }
        else:
            return {"status": "failed", "message": "未识别到骨架"}
    except Exception as e:
        return {"status": "error", "message": str(e)}
    
   
@app.get("/history")
def get_history():
    db = SessionLocal()

    try:
        records = db.query(PostureRecord).order_by(PostureRecord.id.desc()).all()

        data = []
        for record in records:
            data.append({
                "id": record.id,
                "filename": record.filename,
                "tilt_angle": record.tilt_angle,
                "diagnosis": record.diagnosis,
                "ai_advice": record.ai_advice,
                "test_time": record.test_time.strftime("%Y-%m-%d %H:%M:%S")
            })

        return {
            "status": "success",
            "data": data
        }
    finally:
        db.close()
        
@app.delete("/history/clear")
def clear_history():
    db = SessionLocal()

    try:
        count = db.query(PostureRecord).count()
        db.query(PostureRecord).delete()
        db.commit()

        return {
            "status": "success",
            "message": "历史记录已清空",
            "deleted_count": count
        }
    except Exception as e:
        db.rollback()
        return {
            "status": "error",
            "message": str(e)
        }
    finally:
        db.close()


@app.delete("/history/{record_id}")
def delete_history_record(record_id: int):
    db = SessionLocal()

    try:
        record = db.query(PostureRecord).filter(PostureRecord.id == record_id).first()

        if record is None:
            return {
                "status": "error",
                "message": "记录不存在"
            }

        db.delete(record)
        db.commit()

        return {
            "status": "success",
            "message": "记录删除成功",
            "deleted_id": record_id
        }
    except Exception as e:
        db.rollback()
        return {
            "status": "error",
            "message": str(e)
        }
    finally:
        db.close()