import { router } from '@kit.ArkUI'

interface AnalyzeResult {
  status?: string
  filename?: string
  tilt_angle?: number
  diagnosis?: string
  ai_coach?: string
  ai_advice?: string
  image_base64?: string
  message?: string
}

class ExerciseItem {
  title: string
  desc: string

  constructor(title: string, desc: string) {
    this.title = title
    this.desc = desc
  }
}

@Entry
@Component
struct ResultPage {
  @State score: number = 0
  @State angle: number = 0
  @State diagnosis: string = '暂无诊断结果'
  @State advice: string = '暂无 AI 建议'
  @State filename: string = ''
  @State parseTip: string = ''
  @State resultImage: string = ''

  private exercises: ExerciseItem[] = [
    new ExerciseItem('靠墙站立训练', '背部、肩胛骨和后脑勺贴墙，保持 1 分钟。'),
    new ExerciseItem('肩颈侧向拉伸', '头部缓慢向一侧倾斜，拉伸肩颈肌肉，每侧 20 秒。'),
    new ExerciseItem('胸椎打开练习', '双手交叉放于脑后，缓慢打开胸腔，改善圆肩姿态。')
  ]

  aboutToAppear() {
    this.loadAnalyzeResult()
  }

  loadAnalyzeResult() {
    try {
      const params = router.getParams() as Record<string, string>

      if (params && params.result) {
        const result = JSON.parse(params.result) as AnalyzeResult

        this.angle = Number(result.tilt_angle || 0)
        this.score = this.getScoreByAngle(this.angle)
        this.diagnosis = String(result.diagnosis || '暂无诊断结果')
        this.advice = String(result.ai_coach || result.ai_advice || '暂无 AI 建议')
        this.filename = String(result.filename || 'posture_upload.jpg')

        if (result.image_base64) {
          this.resultImage = 'data:image/jpeg;base64,' + String(result.image_base64)
        } else {
          this.resultImage = ''
        }

        this.parseTip = '已加载真实检测结果'
      } else {
        this.angle = 3.2
        this.score = 86
        this.diagnosis = '存在轻微高低肩风险'
        this.advice = '当前为默认演示数据，未接收到后端返回结果。'
        this.filename = 'demo.jpg'
        this.resultImage = ''
        this.parseTip = '未接收到后端数据，显示默认结果'
      }
    } catch (error) {
      this.angle = 3.2
      this.score = 86
      this.diagnosis = '存在轻微高低肩风险'
      this.advice = '检测结果解析失败，请检查后端返回格式。'
      this.filename = 'unknown.jpg'
      this.resultImage = ''
      this.parseTip = '结果解析失败：' + String(error)
    }
  }

  getScoreByAngle(angle: number): number {
    if (angle <= 1) {
      return 98
    }
    if (angle <= 2) {
      return 92
    }
    if (angle <= 3) {
      return 86
    }
    if (angle <= 5) {
      return 78
    }
    if (angle <= 8) {
      return 68
    }
    return 55
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('‹')
          .fontSize(34)
          .fontColor(Color.White)
          .onClick(() => {
            router.back()
          })

        Text('检测结果')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ left: 12 })
          .layoutWeight(1)

        Text('档案')
          .fontSize(14)
          .fontColor('#00D4FF')
          .onClick(() => {
            router.pushUrl({
              url: 'pages/HistoryPage'
            })
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 48, bottom: 12 })

      Scroll() {
        Column() {
          // 检测完成提示
          Row() {
            Text('✓')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#07120B')
              .width(32)
              .height(32)
              .textAlign(TextAlign.Center)
              .backgroundColor('#00E676')
              .borderRadius(16)

            Column() {
              Text('AI 检测已完成')
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)

              Text(this.parseTip)
                .fontSize(12)
                .fontColor('#8EA2AE')
                .margin({ top: 5 })
            }
            .margin({ left: 12 })
            .layoutWeight(1)
          }
          .width('88%')
          .padding(16)
          .backgroundColor('#111821')
          .borderRadius(18)
          .border({
            width: 1,
            color: '#1F3A4A'
          })

          // 骨架图结果卡片
          Column() {
            Row() {
              Text('骨架识别结果')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .layoutWeight(1)

              Text('MediaPipe')
                .fontSize(12)
                .fontColor('#00D4FF')
                .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                .backgroundColor('#102536')
                .borderRadius(14)
            }
            .width('100%')

            Column() {
              if (this.resultImage !== '') {
                Image(this.resultImage)
                  .width('100%')
                  .height(220)
                  .objectFit(ImageFit.Contain)
                  .borderRadius(14)

                Text('检测文件：' + this.filename)
                  .fontSize(12)
                  .fontColor('#8EA2AE')
                  .margin({ top: 8 })
              } else {
                Text('人体骨架图')
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#00E676')

                Text('未获取到后端返回的骨架识别图片')
                  .fontSize(13)
                  .fontColor('#8EA2AE')
                  .margin({ top: 10 })

                Text('检测文件：' + this.filename)
                  .fontSize(12)
                  .fontColor('#8EA2AE')
                  .margin({ top: 8 })
              }
            }
            .width('100%')
            .height(260)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .margin({ top: 18 })
            .backgroundColor('#0B111A')
            .borderRadius(20)
            .border({
              width: 1,
              color: '#1F3A4A'
            })
          }
          .width('88%')
          .padding(20)
          .margin({ top: 22 })
          .backgroundColor('#111821')
          .borderRadius(22)
          .border({
            width: 1,
            color: '#1F3A4A'
          })

          // 评分卡片
          Column() {
            Row() {
              Column() {
                Text('体态评分')
                  .fontSize(14)
                  .fontColor('#8EA2AE')

                Row() {
                  Text(this.score.toString())
                    .fontSize(52)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#00E676')

                  Text(' / 100')
                    .fontSize(18)
                    .fontColor('#8EA2AE')
                    .margin({ top: 22 })
                }
                .margin({ top: 8 })
              }
              .layoutWeight(1)

              Column() {
                Text('高低肩倾角')
                  .fontSize(14)
                  .fontColor('#8EA2AE')

                Text(this.angle.toFixed(1) + '°')
                  .fontSize(34)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
                  .margin({ top: 16 })
              }
              .alignItems(HorizontalAlign.End)
            }
            .width('100%')

            Divider()
              .color('#1F3A4A')
              .margin({ top: 18, bottom: 18 })

            Row() {
              Text('风险判断')
                .fontSize(14)
                .fontColor('#8EA2AE')
                .layoutWeight(1)

              Text(this.diagnosis)
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#00D4FF')
            }
            .width('100%')
          }
          .width('88%')
          .padding(20)
          .margin({ top: 22 })
          .backgroundColor('#111821')
          .borderRadius(22)
          .border({
            width: 1,
            color: '#1F3A4A'
          })

          // AI 建议
          Column() {
            Row() {
              Text('AI 康复建议')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .layoutWeight(1)

              Text('GLM')
                .fontSize(12)
                .fontColor('#07120B')
                .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                .backgroundColor('#00E676')
                .borderRadius(14)
            }
            .width('100%')

            Text(this.advice)
              .fontSize(15)
              .fontColor('#D8E4EA')
              .lineHeight(26)
              .margin({ top: 16 })
              .width('100%')
          }
          .width('88%')
          .padding(20)
          .margin({ top: 22 })
          .backgroundColor('#111821')
          .borderRadius(22)
          .border({
            width: 1,
            color: '#1C2B36'
          })

          // 推荐训练
          Column() {
            Text('推荐训练')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .width('100%')
              .margin({ bottom: 14 })

            ForEach(this.exercises, (item: ExerciseItem, index: number) => {
              this.ExerciseCard((index + 1).toString(), item.title, item.desc)
            })
          }
          .width('88%')
          .padding(20)
          .margin({ top: 22 })
          .backgroundColor('#111821')
          .borderRadius(22)
          .border({
            width: 1,
            color: '#1C2B36'
          })

          // 操作按钮
          Column() {
            Button('查看完整报告')
              .width('100%')
              .height(50)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#07120B')
              .backgroundColor('#00E676')
              .borderRadius(25)
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/ReportPage',
                  params: {
                    score: this.score.toString(),
                    angle: this.angle.toFixed(1),
                    diagnosis: this.diagnosis,
                    advice: this.advice,
                    filename: this.filename
                  }
                })
              })

            Button('查看健康档案')
              .width('100%')
              .height(48)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .backgroundColor('#102536')
              .borderRadius(24)
              .margin({ top: 14 })
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/HistoryPage'
                })
              })

            Button('重新检测')
              .width('100%')
              .height(48)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .backgroundColor('#102536')
              .borderRadius(24)
              .margin({ top: 14 })
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/DetectPage'
                })
              })
          }
          .width('88%')
          .margin({ top: 22, bottom: 36 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#070B12')
  }

  @Builder
  ExerciseCard(index: string, title: string, desc: string) {
    Row() {
      Text(index)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#07120B')
        .width(30)
        .height(30)
        .textAlign(TextAlign.Center)
        .backgroundColor(index === '2' ? '#00D4FF' : '#00E676')
        .borderRadius(15)

      Column() {
        Text(title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)

        Text(desc)
          .fontSize(12)
          .fontColor('#8EA2AE')
          .lineHeight(20)
          .margin({ top: 5 })
      }
      .layoutWeight(1)
      .margin({ left: 12 })
    }
    .width('100%')
    .padding(14)
    .margin({ bottom: 10 })
    .backgroundColor('#0B111A')
    .borderRadius(16)
  }
}