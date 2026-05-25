import { router } from '@kit.ArkUI'

@Entry
@Component
struct ReportPage {
  @State score: string = '--'
  @State angle: string = '--'
  @State diagnosis: string = '暂无诊断结果'
  @State advice: string = '暂无 AI 建议'
  @State filename: string = 'posture_upload.jpg'
  @State reportTime: string = ''

  aboutToAppear() {
    this.loadReportData()
  }

  loadReportData() {
    try {
      const params = router.getParams() as Record<string, string>

      if (params) {
        this.score = String(params.score || '--')
        this.angle = String(params.angle || '--')
        this.diagnosis = String(params.diagnosis || '暂无诊断结果')
        this.advice = String(params.advice || '暂无 AI 建议')
        this.filename = String(params.filename || 'posture_upload.jpg')
      }

      this.reportTime = this.getCurrentTime()
    } catch (error) {
      this.reportTime = this.getCurrentTime()
    }
  }

  getCurrentTime(): string {
    const date = new Date()
    const year = date.getFullYear()
    const month = this.fillZero(date.getMonth() + 1)
    const day = this.fillZero(date.getDate())
    const hour = this.fillZero(date.getHours())
    const minute = this.fillZero(date.getMinutes())

    return year + '-' + month + '-' + day + ' ' + hour + ':' + minute
  }

  fillZero(value: number): string {
    if (value < 10) {
      return '0' + value.toString()
    }

    return value.toString()
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

        Text('检测报告')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ left: 12 })
          .layoutWeight(1)

        Text('完成')
          .fontSize(14)
          .fontColor('#00D4FF')
          .onClick(() => {
            router.pushUrl({
              url: 'pages/Index'
            })
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 48, bottom: 12 })

      Scroll() {
        Column() {
          // 报告标题卡片
          Column() {
            Row() {
              Column() {
                Text('Posture.AI')
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)

                Text('AI 体态智能检测报告')
                  .fontSize(15)
                  .fontColor('#8EA2AE')
                  .margin({ top: 8 })
              }
              .layoutWeight(1)

              Text('AI')
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor('#07120B')
                .width(56)
                .height(56)
                .textAlign(TextAlign.Center)
                .backgroundColor('#00E676')
                .borderRadius(28)
            }
            .width('100%')

            Divider()
              .color('#1F3A4A')
              .margin({ top: 18, bottom: 18 })

            Row() {
              Text('报告生成时间')
                .fontSize(13)
                .fontColor('#8EA2AE')
                .layoutWeight(1)

              Text(this.reportTime)
                .fontSize(13)
                .fontColor(Color.White)
            }
            .width('100%')

            Row() {
              Text('检测文件')
                .fontSize(13)
                .fontColor('#8EA2AE')
                .layoutWeight(1)

              Text(this.filename)
                .fontSize(13)
                .fontColor('#00D4FF')
            }
            .width('100%')
            .margin({ top: 10 })
          }
          .width('88%')
          .padding(20)
          .backgroundColor('#111821')
          .borderRadius(22)
          .border({
            width: 1,
            color: '#1F3A4A'
          })

          // 核心结果
          Column() {
            Text('一、核心检测结果')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .width('100%')

            Row() {
              this.ResultBlock('体态评分', this.score, '分', '#00E676')
              Blank().width(12)
              this.ResultBlock('高低肩倾角', this.angle, '°', '#00D4FF')
            }
            .width('100%')
            .margin({ top: 18 })

            Row() {
              Text('风险判断')
                .fontSize(14)
                .fontColor('#8EA2AE')
                .layoutWeight(1)

              Text(this.diagnosis)
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor('#00D4FF')
            }
            .width('100%')
            .padding(16)
            .margin({ top: 14 })
            .backgroundColor('#0B111A')
            .borderRadius(16)
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
              Text('二、AI 康复建议')
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
              .width('100%')
              .margin({ top: 16 })
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

          // 训练计划
          Column() {
            Text('三、推荐训练计划')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .width('100%')
              .margin({ bottom: 14 })

            this.PlanItem('1', '靠墙站立训练', '每日 2 组，每组 1 分钟，帮助肩背回到自然中立位置。')
            this.PlanItem('2', '肩颈侧向拉伸', '左右各 20 秒，重复 3 组，缓解肩颈紧张。')
            this.PlanItem('3', '胸椎打开练习', '每日 5 分钟，改善圆肩和含胸问题。')
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

          // 报告说明
          Column() {
            Text('四、报告说明')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .width('100%')

            Text('本报告基于上传照片中的人体骨架关键点识别结果生成，主要用于课程设计演示和日常体态参考。若存在明显疼痛、长期不适或严重体态异常，建议咨询专业医生或康复师。')
              .fontSize(14)
              .fontColor('#B9C7D0')
              .lineHeight(24)
              .margin({ top: 12 })
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

          // 操作按钮
          Column() {
            Button('返回结果页')
              .width('100%')
              .height(50)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#07120B')
              .backgroundColor('#00E676')
              .borderRadius(25)
              .onClick(() => {
                router.back()
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
  ResultBlock(title: string, value: string, unit: string, color: string) {
    Column() {
      Text(title)
        .fontSize(12)
        .fontColor('#8EA2AE')

      Row() {
        Text(value)
          .fontSize(34)
          .fontWeight(FontWeight.Bold)
          .fontColor(color)

        Text(unit)
          .fontSize(14)
          .fontColor('#8EA2AE')
          .margin({ left: 4, top: 14 })
      }
      .margin({ top: 8 })
    }
    .layoutWeight(1)
    .padding(16)
    .backgroundColor('#0B111A')
    .borderRadius(16)
  }

  @Builder
  PlanItem(index: string, title: string, desc: string) {
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
          .fontWeight(FontWeight.Bold)
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