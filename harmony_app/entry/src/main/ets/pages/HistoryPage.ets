import { router } from '@kit.ArkUI'
import { preferences } from '@kit.ArkData'
import { ApiService, PostureHistoryRecord } from '../services/ApiService'
import { HistoryViewModel } from '../viewmodels/HistoryViewModel'

@Entry
@Component
struct HistoryPage {
  @State baseUrl: string = 'http://192.168.0.200:8000'
  @State historyList: PostureHistoryRecord[] = []
  @State loading: boolean = false
  @State errorMessage: string = ''
  @State actionTip: string = ''

  @State avgScoreText: string = '--'
  @State avgAngleText: string = '--'
  @State riskCountText: string = '0'
  @State bestScoreText: string = '--'

  private settingStore: preferences.Preferences | undefined = undefined
  private readonly STORE_NAME: string = 'PostureAISettings'
  private readonly KEY_BASE_URL: string = 'baseUrl'

  aboutToAppear() {
    this.loadBaseUrl()
    this.loadHistory()
  }

  loadBaseUrl() {
    try {
      this.settingStore = preferences.getPreferencesSync(getContext(this), {
        name: this.STORE_NAME
      })

      const savedUrl = this.settingStore.getSync(this.KEY_BASE_URL, this.baseUrl) as string
      this.baseUrl = savedUrl
    } catch (error) {
      this.baseUrl = 'http://192.168.0.200:8000'
    }
  }

  loadHistory() {
    this.loading = true
    this.errorMessage = ''

    ApiService.getHistory(this.baseUrl)
      .then((list: PostureHistoryRecord[]) => {
        this.loading = false

        const sortedList = HistoryViewModel.sortByLatest(list)
        this.historyList = sortedList
        this.updateStatsByList(sortedList)
      })
      .catch((message: string) => {
        this.loading = false
        this.errorMessage = message
        this.historyList = []
        this.updateStatsByList([])
      })
  }

  confirmDeleteRecord(item: PostureHistoryRecord) {
    AlertDialog.show({
      title: '删除记录',
      message: '确认删除这条检测记录吗？删除后无法恢复。',
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '删除',
        action: () => {
          this.deleteRecord(Number(item.id))
        }
      }
    })
  }

  confirmClearHistory() {
    if (this.historyList.length === 0) {
      this.actionTip = '当前没有可清空的历史记录'
      return
    }

    AlertDialog.show({
      title: '清空历史记录',
      message: '确认清空全部检测历史吗？清空后无法恢复。',
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '确认清空',
        action: () => {
          this.clearAllHistory()
        }
      }
    })
  }

  deleteRecord(recordId: number) {
    this.loading = true
    this.actionTip = ''
    this.errorMessage = ''

    ApiService.deleteHistory(this.baseUrl, recordId)
      .then(() => {
        this.actionTip = '记录已删除'
        this.loadHistory()
      })
      .catch((message: string) => {
        this.loading = false
        this.errorMessage = message
      })
  }

  clearAllHistory() {
    this.loading = true
    this.actionTip = ''
    this.errorMessage = ''

    ApiService.clearHistory(this.baseUrl)
      .then(() => {
        this.actionTip = '历史记录已清空'
        this.loadHistory()
      })
      .catch((message: string) => {
        this.loading = false
        this.errorMessage = message
      })
  }

  goDetail(item: PostureHistoryRecord) {
    router.pushUrl({
      url: 'pages/HistoryDetailPage',
      params: {
        id: String(item.id),
        filename: String(item.filename),
        testTime: String(item.test_time),
        score: this.getScoreByAngle(Number(item.tilt_angle)).toString(),
        angle: Number(item.tilt_angle).toFixed(1),
        diagnosis: String(item.diagnosis),
        advice: String(item.ai_advice || '暂无 AI 建议')
      }
    })
  }

  build() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(34)
          .fontColor(Color.White)
          .onClick(() => {
            router.back()
          })

        Text('健康档案')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ left: 12 })
          .layoutWeight(1)

        Text('清空')
          .fontSize(14)
          .fontColor('#FF6B6B')
          .margin({ right: 16 })
          .onClick(() => {
            this.confirmClearHistory()
          })

        Text(this.loading ? '加载中' : '刷新')
          .fontSize(14)
          .fontColor('#00D4FF')
          .onClick(() => {
            if (!this.loading) {
              this.actionTip = ''
              this.loadHistory()
            }
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 48, bottom: 12 })

      Scroll() {
        Column() {
          if (this.errorMessage !== '') {
            Text('操作失败：' + this.errorMessage)
              .fontSize(14)
              .fontColor('#FF6B6B')
              .width('88%')
              .padding(14)
              .backgroundColor('#111821')
              .borderRadius(14)
              .margin({ bottom: 12 })
          }

          if (this.actionTip !== '') {
            Text(this.actionTip)
              .fontSize(14)
              .fontColor('#00E676')
              .width('88%')
              .padding(14)
              .backgroundColor('#111821')
              .borderRadius(14)
              .margin({ bottom: 12 })
          }

          // 总览卡片
          Column() {
            Row() {
              Text('体态健康总览')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .layoutWeight(1)

              Text(this.historyList.length.toString() + ' 条')
                .fontSize(12)
                .fontColor('#07120B')
                .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                .backgroundColor('#00E676')
                .borderRadius(14)
            }
            .width('100%')

            Row() {
              Column() {
                Text('平均评分')
                  .fontSize(12)
                  .fontColor('#8EA2AE')

                Row() {
                  Text(this.avgScoreText)
                    .fontSize(28)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#00E676')

                  Text('分')
                    .fontSize(13)
                    .fontColor('#8EA2AE')
                    .margin({ left: 4, top: 10 })
                }
                .margin({ top: 6 })
              }
              .layoutWeight(1)
              .padding(14)
              .backgroundColor('#0B111A')
              .borderRadius(16)

              Blank().width(12)

              Column() {
                Text('平均倾角')
                  .fontSize(12)
                  .fontColor('#8EA2AE')

                Row() {
                  Text(this.avgAngleText)
                    .fontSize(28)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#00D4FF')

                  Text('°')
                    .fontSize(13)
                    .fontColor('#8EA2AE')
                    .margin({ left: 4, top: 10 })
                }
                .margin({ top: 6 })
              }
              .layoutWeight(1)
              .padding(14)
              .backgroundColor('#0B111A')
              .borderRadius(16)
            }
            .width('100%')
            .margin({ top: 18 })

            Row() {
              Column() {
                Text('风险次数')
                  .fontSize(12)
                  .fontColor('#8EA2AE')

                Row() {
                  Text(this.riskCountText)
                    .fontSize(28)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#00E676')

                  Text('次')
                    .fontSize(13)
                    .fontColor('#8EA2AE')
                    .margin({ left: 4, top: 10 })
                }
                .margin({ top: 6 })
              }
              .layoutWeight(1)
              .padding(14)
              .backgroundColor('#0B111A')
              .borderRadius(16)

              Blank().width(12)

              Column() {
                Text('最佳评分')
                  .fontSize(12)
                  .fontColor('#8EA2AE')

                Row() {
                  Text(this.bestScoreText)
                    .fontSize(28)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#00D4FF')

                  Text('分')
                    .fontSize(13)
                    .fontColor('#8EA2AE')
                    .margin({ left: 4, top: 10 })
                }
                .margin({ top: 6 })
              }
              .layoutWeight(1)
              .padding(14)
              .backgroundColor('#0B111A')
              .borderRadius(16)
            }
            .width('100%')
            .margin({ top: 12 })
          }
          .width('88%')
          .padding(20)
          .backgroundColor('#111821')
          .borderRadius(22)
          .border({
            width: 1,
            color: '#1F3A4A'
          })

          // 趋势分析
          Column() {
            Text('倾角变化趋势')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .width('100%')

            Text('数值越低表示肩部越接近水平状态')
              .fontSize(12)
              .fontColor('#8EA2AE')
              .width('100%')
              .margin({ top: 8, bottom: 16 })

            if (this.historyList.length === 0) {
              Text('暂无趋势数据')
                .fontSize(14)
                .fontColor('#8EA2AE')
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding(20)
            } else {
              ForEach(this.getTrendList(), (item: PostureHistoryRecord) => {
                this.TrendBar(
                  item.test_time.substring(5, 10),
                  Number(item.tilt_angle),
                  this.getAnglePercent(Number(item.tilt_angle))
                )
              })
            }
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

          // 历史记录列表
          Column() {
            Row() {
              Text('历史检测记录')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .layoutWeight(1)

              Text(this.historyList.length.toString() + ' 条')
                .fontSize(13)
                .fontColor('#8EA2AE')
            }
            .width('100%')
            .margin({ bottom: 14 })

            if (this.historyList.length === 0) {
              Text('暂无检测记录，请先完成一次 AI 体态检测')
                .fontSize(14)
                .fontColor('#8EA2AE')
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding(24)
                .backgroundColor('#0B111A')
                .borderRadius(16)
            } else {
              ForEach(this.historyList, (item: PostureHistoryRecord, index: number) => {
                this.RecordCard(item, index)
              })
            }
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

          // 改善建议
          Column() {
            Text('改善建议')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .width('100%')

            Text(this.getSummaryAdvice())
              .fontSize(14)
              .fontColor('#B9C7D0')
              .lineHeight(24)
              .margin({ top: 12 })
              .width('100%')
          }
          .width('88%')
          .padding(20)
          .margin({ top: 22, bottom: 36 })
          .backgroundColor('#111821')
          .borderRadius(22)
          .border({
            width: 1,
            color: '#1C2B36'
          })
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

  getScoreByAngle(angle: number): number {
    return HistoryViewModel.getScoreByAngle(angle)
  }

  updateStatsByList(list: PostureHistoryRecord[]) {
    const stats = HistoryViewModel.calculateStats(list)

    this.avgScoreText = stats.avgScoreText
    this.avgAngleText = stats.avgAngleText
    this.riskCountText = stats.riskCountText
    this.bestScoreText = stats.bestScoreText
  }

  getTrendList(): PostureHistoryRecord[] {
    return HistoryViewModel.getTrendList(this.historyList)
  }

  getAnglePercent(angle: number): number {
    return HistoryViewModel.getAnglePercent(angle)
  }

  getSummaryAdvice(): string {
    return HistoryViewModel.getSummaryAdvice(this.historyList)
  }

  @Builder
  TrendBar(date: string, angle: number, percent: number) {
    Row() {
      Text(date)
        .fontSize(12)
        .fontColor('#8EA2AE')
        .width(48)

      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width('100%')
          .height(10)
          .backgroundColor('#0B111A')
          .borderRadius(5)

        Row()
          .width(percent.toString() + '%')
          .height(10)
          .backgroundColor(angle > 3 ? '#00D4FF' : '#00E676')
          .borderRadius(5)
      }
      .height(10)
      .layoutWeight(1)
      .margin({ left: 10, right: 10 })

      Text(angle.toFixed(1) + '°')
        .fontSize(12)
        .fontColor(Color.White)
        .width(40)
    }
    .width('100%')
    .margin({ bottom: 14 })
  }

  @Builder
  RecordCard(item: PostureHistoryRecord, index: number) {
    Column() {
      Row() {
        Column() {
          Text(item.test_time)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)

          Text(item.filename)
            .fontSize(12)
            .fontColor('#8EA2AE')
            .margin({ top: 6 })

          Row() {
            Text(item.diagnosis)
              .fontSize(12)
              .fontColor(Number(item.tilt_angle) > 3 ? '#00D4FF' : '#00E676')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor('#102536')
              .borderRadius(12)

            Text(index === 0 ? '最新检测' : '历史记录')
              .fontSize(12)
              .fontColor('#8EA2AE')
              .margin({ left: 8 })
          }
          .margin({ top: 8 })
        }
        .layoutWeight(1)

        Column() {
          Text(this.getScoreByAngle(Number(item.tilt_angle)).toString() + '分')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#00E676')

          Text(Number(item.tilt_angle).toFixed(1) + '°')
            .fontSize(13)
            .fontColor('#00D4FF')
            .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')

      Row() {
        Text('查看详情')
          .fontSize(13)
          .fontColor('#07120B')
          .padding({ left: 14, right: 14, top: 7, bottom: 7 })
          .backgroundColor('#00E676')
          .borderRadius(16)
          .onClick(() => {
            this.goDetail(item)
          })

        Blank()
          .layoutWeight(1)

        Text('删除')
          .fontSize(13)
          .fontColor('#FF6B6B')
          .padding({ left: 14, right: 14, top: 7, bottom: 7 })
          .backgroundColor('#201116')
          .borderRadius(16)
          .onClick(() => {
            this.confirmDeleteRecord(item)
          })
      }
      .width('100%')
      .margin({ top: 14 })
    }
    .width('100%')
    .padding(16)
    .margin({ bottom: 12 })
    .backgroundColor('#0B111A')
    .borderRadius(16)
    .border({
      width: 1,
      color: index === 0 ? '#00E676' : '#1C2B36'
    })
  }
}