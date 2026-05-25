import { router } from '@kit.ArkUI'
import { preferences } from '@kit.ArkData'
import { ApiService, PostureHistoryRecord } from '../services/ApiService'

@Entry
@Component
struct Index {

  @State appName: string = '塑影 Posture.AI'
  @State slogan: string = 'AI 体态智能检测系统'
  @State lastScore: number = 0
  @State lastAngle: number = 0
  @State lastDiagnosis: string = '暂无检测记录'
  @State hasRecord: boolean = false
  @State loadingHistory: boolean = false
  @State baseUrl: string = 'http://192.168.0.198:8000'

  private settingStore: preferences.Preferences | undefined = undefined
  private readonly STORE_NAME: string = 'PostureAISettings'
  private readonly KEY_BASE_URL: string = 'baseUrl'

  private features: string[] = [
    'AI 视觉骨架识别',
    '高低肩角度计算',
    '大模型康复建议',
    '健康档案管理'
  ]
  aboutToAppear() {
    this.loadBaseUrl()
    this.loadLatestRecord()
  }

  onPageShow() {
    this.loadBaseUrl()
    this.loadLatestRecord()
  }
  loadBaseUrl() {
    try {
      this.settingStore = preferences.getPreferencesSync(getContext(this), {
        name: this.STORE_NAME
      })

      const savedUrl = this.settingStore.getSync(this.KEY_BASE_URL, this.baseUrl) as string
      this.baseUrl = savedUrl
    } catch (error) {
      this.baseUrl = 'http://192.168.0.198:8000'
    }
  }

  loadLatestRecord() {
    this.loadingHistory = true

    ApiService.getHistory(this.baseUrl)
      .then((list: PostureHistoryRecord[]) => {
        this.loadingHistory = false

        if (list.length > 0) {
          const sortedList = list.sort((a: PostureHistoryRecord, b: PostureHistoryRecord) => {
            return Number(b.id) - Number(a.id)
          })

          const latest = sortedList[0]
          const angle = Number(latest.tilt_angle)

          this.lastAngle = angle
          this.lastScore = this.getScoreByAngle(angle)
          this.lastDiagnosis = latest.diagnosis
          this.hasRecord = true
        } else {
          this.lastScore = 0
          this.lastAngle = 0
          this.lastDiagnosis = '暂无检测记录'
          this.hasRecord = false
        }
      })
      .catch(() => {
        this.loadingHistory = false
        this.lastScore = 0
        this.lastAngle = 0
        this.lastDiagnosis = '后端连接失败，请检查系统设置'
        this.hasRecord = false
      })
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
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#070B12')

      Scroll() {
        Column() {
          // 顶部标题区域
          Column() {
            Row() {
              Column() {
                Text(this.appName)
                  .fontSize(30)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)

                Text(this.slogan)
                  .fontSize(15)
                  .fontColor('#9BB8C9')
                  .margin({ top: 8 })

                Text('基于 HarmonyOS 与 AIGC 的智能体态检测健康管理系统')
                  .fontSize(13)
                  .fontColor('#D8E4EA')
                  .lineHeight(22)
                  .margin({ top: 14 })
              }
              .layoutWeight(1)

              Stack({ alignContent: Alignment.Center }) {
                Image($r('app.media.app_logo'))
                  .width(78)
                  .height(78)
                  .objectFit(ImageFit.Contain)
                  .borderRadius(39)
              }
              .width(82)
              .height(82)
              .backgroundColor('#07120B')
              .borderRadius(41)
              .border({
                width: 1,
                color: '#1F3A4A'
              })
            }
            .width('100%')
            .padding({ left: 24, right: 24, top: 48 })
          }
          .width('100%')

          // 检测入口卡片
          Column() {
            Row() {
              Text('智能检测')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .layoutWeight(1)

              Text('AI Vision')
                .fontSize(12)
                .fontColor('#00D4FF')
                .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                .backgroundColor('#102536')
                .borderRadius(14)
            }
            .width('100%')

            Text('上传一张人体照片，系统将自动识别人体骨架关键点，计算高低肩倾斜角度，并生成 AI 康复建议。')
              .fontSize(14)
              .fontColor('#B9C7D0')
              .lineHeight(24)
              .margin({ top: 14 })

            Button('开始体态检测')
              .width('100%')
              .height(52)
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor('#07120B')
              .backgroundColor('#00E676')
              .borderRadius(26)
              .margin({ top: 24 })
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/DetectPage'
                })
              })

            Row() {
              Button('健康档案')
                .layoutWeight(1)
                .height(44)
                .fontSize(15)
                .fontColor(Color.White)
                .backgroundColor('#102536')
                .borderRadius(22)
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/HistoryPage'
                  })
                })

              Blank()
                .width(12)

              Button('系统设置')
                .layoutWeight(1)
                .height(44)
                .fontSize(15)
                .fontColor(Color.White)
                .backgroundColor('#102536')
                .borderRadius(22)
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/SettingsPage'
                  })
                })
            }
            .width('100%')
            .margin({ top: 14 })
          }
          .width('88%')
          .padding(20)
          .margin({ top: 30 })
          .backgroundColor('#111821')
          .borderRadius(22)
          .border({
            width: 1,
            color: '#1F3A4A'
          })

          // 最近检测结果
          Column() {
            Row() {
              Text('最近一次检测')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .layoutWeight(1)

              Text('健康档案')
                .fontSize(13)
                .fontColor('#00D4FF')
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/HistoryPage'
                  })
                })
            }
            .width('100%')

            Row() {
              Column() {
                Text('体态评分')
                  .fontSize(13)
                  .fontColor('#8EA2AE')

                Row() {
                  Text(this.lastScore.toString())
                    .fontSize(44)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#00E676')

                  Text(' / 100')
                    .fontSize(16)
                    .fontColor('#8EA2AE')
                    .margin({ top: 18 })
                }
                .margin({ top: 8 })
              }
              .layoutWeight(1)

              Column() {
                Text('高低肩倾角')
                  .fontSize(13)
                  .fontColor('#8EA2AE')

                Text(this.lastAngle.toFixed(1) + '°')
                  .fontSize(30)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
                  .margin({ top: 12 })
              }
              .alignItems(HorizontalAlign.End)
            }
            .width('100%')
            .margin({ top: 22 })

            Row() {
              Text('状态评估')
                .fontSize(12)
                .fontColor('#07120B')
                .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                .backgroundColor('#00E676')
                .borderRadius(14)

              Text(this.loadingHistory ? '正在加载最近检测记录...' : this.lastDiagnosis)
                .fontSize(13)
                .fontColor('#B9C7D0')
                .lineHeight(22)
                .margin({ left: 12 })
                .layoutWeight(1)
            }
            .width('100%')
            .margin({ top: 18 })
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

          // 核心功能
          Column() {
            Text('核心功能')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .width('100%')
              .margin({ bottom: 14 })

            ForEach(this.features, (item: string, index: number) => {
              Row() {
                Text((index + 1).toString())
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#07120B')
                  .width(30)
                  .height(30)
                  .textAlign(TextAlign.Center)
                  .backgroundColor(index % 2 === 0 ? '#00E676' : '#00D4FF')
                  .borderRadius(15)

                Column() {
                  Text(item)
                    .fontSize(15)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Color.White)

                  Text(this.getFeatureDesc(index))
                    .fontSize(12)
                    .fontColor('#8EA2AE')
                    .margin({ top: 5 })
                }
                .margin({ left: 12 })
                .layoutWeight(1)
              }
              .width('100%')
              .padding(16)
              .margin({ bottom: 12 })
              .backgroundColor('#111821')
              .borderRadius(18)
              .border({
                width: 1,
                color: '#1C2B36'
              })
            })
          }
          .width('88%')
          .margin({ top: 28 })


        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  getFeatureDesc(index: number): string {
    if (index === 0) {
      return '识别人体关键点并绘制骨架结果'
    }
    if (index === 1) {
      return '量化肩部倾斜角度并生成体态评分'
    }
    if (index === 2) {
      return '结合检测结果生成个性化康复建议'
    }
    return '保存每次检测结果，追踪体态变化'
  }
}