import { router } from '@kit.ArkUI'

@Entry
@Component
struct HistoryDetailPage {
  @State recordId: string = ''
  @State filename: string = 'posture_upload.jpg'
  @State testTime: string = '--'
  @State score: string = '--'
  @State angle: string = '--'
  @State diagnosis: string = '暂无诊断结果'
  @State advice: string = '暂无 AI 建议'

  aboutToAppear() {
    this.loadDetailData()
  }

  loadDetailData() {
    try {
      const params = router.getParams() as Record<string, string>

      if (params) {
        this.recordId = String(params.id || '')
        this.filename = String(params.filename || 'posture_upload.jpg')
        this.testTime = String(params.testTime || '--')
        this.score = String(params.score || '--')
        this.angle = String(params.angle || '--')
        this.diagnosis = String(params.diagnosis || '暂无诊断结果')
        this.advice = String(params.advice || '暂无 AI 建议')
      }
    } catch (error) {
      this.diagnosis = '详情数据解析失败'
      this.advice = '请返回健康档案页后重新进入该记录。'
    }
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

        Text('检测详情')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ left: 12 })
          .layoutWeight(1)

        Text('档案')
          .fontSize(14)
          .fontColor('#00D4FF')
          .onClick(() => {
            router.back()
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 48, bottom: 12 })

      Scroll() {
        Column() {
          // 顶部概要卡片
          Column() {
            Row() {
              Column() {
                Text('历史检测记录')
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)

                Text('Posture.AI 体态检测详情')
                  .fontSize(14)
                  .fontColor('#8EA2AE')
                  .margin({ top: 8 })
              }
              .layoutWeight(1)

              Text('AI')
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor('#07120B')
                .width(54)
                .height(54)
                .textAlign(TextAlign.Center)
                .backgroundColor('#00E676')
                .borderRadius(27)
            }
            .width('100%')

            Divider()
              .color('#1F3A4A')
              .margin({ top: 18, bottom: 18 })

            this.InfoRow('记录编号', this.recordId === '' ? '--' : this.recordId)
            this.InfoRow('检测时间', this.testTime)
            this.InfoRow('检测文件', this.filename)
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
            Text('核心检测结果')
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

            Column() {
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

              Text(this.getRiskDescription())
                .fontSize(13)
                .fontColor('#B9C7D0')
                .lineHeight(22)
                .margin({ top: 12 })
                .width('100%')
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

          // 训练建议
          Column() {
            Text('针对性训练建议')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .width('100%')
              .margin({ bottom: 14 })

            this.PlanItem('1', '靠墙站立训练', '背部、肩胛骨和后脑勺贴墙，保持自然呼吸，每次 1 分钟。')
            this.PlanItem('2', '肩颈侧向拉伸', '头部缓慢向一侧倾斜，拉伸肩颈区域，每侧 20 秒。')
            this.PlanItem('3', '坐姿自检提醒', '学习或办公时保持双肩放松，避免长时间低头和单肩受力。')
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
            Button('返回健康档案')
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
          .margin({ top: 22, bottom: 80 })
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

  getRiskDescription(): string {
    const angleValue = Number(this.angle)

    if (angleValue > 3) {
      return '本次检测显示肩部存在一定左右不平衡，建议关注日常坐姿、站姿以及单侧用力习惯。'
    }

    return '本次检测显示肩部倾角处于较理想范围，建议继续保持良好的坐姿和站姿习惯。'
  }

  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(13)
        .fontColor('#8EA2AE')
        .layoutWeight(1)

      Text(value)
        .fontSize(13)
        .fontColor(label === '检测文件' ? '#00D4FF' : Color.White)
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .margin({ bottom: 10 })
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