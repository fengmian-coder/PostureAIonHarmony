import { router } from '@kit.ArkUI'
import { preferences } from '@kit.ArkData'
import { ApiService } from '../services/ApiService'
@Entry
@Component
struct SettingsPage {
  @State baseUrl: string = 'http://192.168.0.200:8000'
  @State saveTip: string = ''
  @State testStatus: string = '未测试'
  @State testing: boolean = false
  @State statusColor: string = '#8EA2AE'

  private settingStore: preferences.Preferences | undefined = undefined
  private readonly STORE_NAME: string = 'PostureAISettings'
  private readonly KEY_BASE_URL: string = 'baseUrl'

  aboutToAppear() {
    this.initPreferences()
  }

  initPreferences() {
    try {
      this.settingStore = preferences.getPreferencesSync(getContext(this), {
        name: this.STORE_NAME
      })

      const savedUrl = this.settingStore.getSync(this.KEY_BASE_URL, this.baseUrl) as string
      this.baseUrl = savedUrl
    } catch (error) {
      this.saveTip = '读取本地配置失败，将使用默认地址'
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

        Text('系统设置')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ left: 12 })
          .layoutWeight(1)

        Text('保存')
          .fontSize(14)
          .fontColor('#00D4FF')
          .onClick(() => {
            this.saveSetting()
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 48, bottom: 12 })

      Scroll() {
        Column() {
          // 后端地址设置卡片
          Column() {
            Row() {
              Text('后端服务地址')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .layoutWeight(1)

              Text('Preferences')
                .fontSize(12)
                .fontColor('#07120B')
                .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                .backgroundColor('#00E676')
                .borderRadius(14)
            }
            .width('100%')

            Text('这里使用 HarmonyOS Preferences 保存后端地址。重新打开 App 后，会自动读取上次保存的配置。')
              .fontSize(13)
              .fontColor('#8EA2AE')
              .lineHeight(22)
              .width('100%')
              .margin({ top: 12 })

            TextInput({
              placeholder: '例如：http://192.168.1.23:8000',
              text: this.baseUrl
            })
              .width('100%')
              .height(50)
              .fontSize(14)
              .fontColor(Color.White)
              .placeholderColor('#6E828F')
              .backgroundColor('#0B111A')
              .borderRadius(14)
              .padding({ left: 14, right: 14 })
              .margin({ top: 18 })
              .onChange((value: string) => {
                this.baseUrl = value
                this.saveTip = ''
                this.testStatus = '未测试'
                this.statusColor = '#8EA2AE'
              })

            Row() {
              Button(this.testing ? '测试中...' : '测试连接')
                .layoutWeight(1)
                .height(48)
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .backgroundColor('#102536')
                .borderRadius(24)
                .onClick(() => {
                  this.testConnection()
                })

              Blank()
                .width(12)

              Button('保存设置')
                .layoutWeight(1)
                .height(48)
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor('#07120B')
                .backgroundColor('#00E676')
                .borderRadius(24)
                .onClick(() => {
                  this.saveSetting()
                })
            }
            .width('100%')
            .margin({ top: 16 })

            Row() {
              Text('连接状态')
                .fontSize(14)
                .fontColor('#8EA2AE')
                .layoutWeight(1)

              Text(this.testStatus)
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.statusColor)
            }
            .width('100%')
            .padding(14)
            .margin({ top: 18 })
            .backgroundColor('#0B111A')
            .borderRadius(14)

            if (this.saveTip !== '') {
              Text(this.saveTip)
                .fontSize(13)
                .fontColor('#00D4FF')
                .lineHeight(22)
                .margin({ top: 14 })
                .width('100%')
            }
          }
          .width('88%')
          .padding(20)
          .backgroundColor('#111821')
          .borderRadius(22)
          .border({
            width: 1,
            color: '#1F3A4A'
          })

          // 接口配置说明
          Column() {
            Text('后端接口')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .width('100%')
              .margin({ bottom: 14 })

            this.ApiItem('GET', '/health', '检测后端服务是否正常运行')
            this.ApiItem('POST', '/analyze_image', '上传图片并返回体态检测结果')
            this.ApiItem('GET', '/history', '获取历史检测记录')
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

          // 联调提示
          Column() {
            Text('模型机联调提示')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .width('100%')
              .margin({ bottom: 12 })

            this.TipItem('1', '电脑和模型机需要连接同一个 Wi-Fi。')
            this.TipItem('2', '后端启动命令建议使用：uvicorn main:app --host 0.0.0.0 --port 8000')
            this.TipItem('3', 'Windows 防火墙需要允许 8000 端口访问。')
            this.TipItem('4', '后端地址已使用 Preferences 保存到本地。')
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

          // 当前配置预览
          Column() {
            Text('当前配置')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .width('100%')

            Text(this.baseUrl)
              .fontSize(14)
              .fontColor('#00D4FF')
              .lineHeight(24)
              .width('100%')
              .margin({ top: 12 })

            Text('保存后可退出页面或重启 App，再进入设置页查看是否仍保留该地址。')
              .fontSize(13)
              .fontColor('#8EA2AE')
              .lineHeight(22)
              .width('100%')
              .margin({ top: 10 })
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

  saveSetting() {
    if (this.baseUrl.trim() === '') {
      this.saveTip = '请输入后端服务地址'
      return
    }

    if (this.settingStore === undefined) {
      this.initPreferences()
    }

    try {
      this.settingStore?.putSync(this.KEY_BASE_URL, this.baseUrl)
      this.settingStore?.flush()
      this.saveTip = '设置已保存到本地：' + this.baseUrl
    } catch (error) {
      this.saveTip = '保存失败，请稍后重试'
    }
  }

  testConnection() {
    if (this.baseUrl.trim() === '') {
      this.testStatus = '地址为空'
      this.statusColor = '#FF6B6B'
      return
    }

    if (this.baseUrl.indexOf('http://') !== 0 && this.baseUrl.indexOf('https://') !== 0) {
      this.testStatus = '地址格式错误'
      this.statusColor = '#FF6B6B'
      return
    }

    this.testing = true
    this.testStatus = '连接中'
    this.statusColor = '#00D4FF'
    this.saveTip = ''

    ApiService.getHealth(this.baseUrl)
      .then((success: boolean) => {
        this.testing = false

        if (success) {
          this.testStatus = '连接正常'
          this.statusColor = '#00E676'
          this.saveTip = '后端连接成功：' + this.baseUrl + '/health'
        } else {
          this.testStatus = '连接失败'
          this.statusColor = '#FF6B6B'
          this.saveTip = '无法连接后端，请检查 IP、端口、防火墙和后端服务'
        }
      })
      .catch(() => {
        this.testing = false
        this.testStatus = '连接失败'
        this.statusColor = '#FF6B6B'
        this.saveTip = '网络请求异常，请检查后端服务是否启动'
      })
  }

  @Builder
  ApiItem(method: string, path: string, desc: string) {
    Row() {
      Text(method)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor(method === 'POST' ? '#07120B' : '#FFFFFF')
        .width(54)
        .height(28)
        .textAlign(TextAlign.Center)
        .backgroundColor(method === 'POST' ? '#00E676' : '#102536')
        .borderRadius(14)

      Column() {
        Text(path)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)

        Text(desc)
          .fontSize(12)
          .fontColor('#8EA2AE')
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

  @Builder
  TipItem(index: string, content: string) {
    Row() {
      Text(index)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor('#07120B')
        .width(26)
        .height(26)
        .textAlign(TextAlign.Center)
        .backgroundColor(index === '2' ? '#00D4FF' : '#00E676')
        .borderRadius(13)

      Text(content)
        .fontSize(13)
        .fontColor('#B9C7D0')
        .lineHeight(22)
        .margin({ left: 10 })
        .layoutWeight(1)
    }
    .width('100%')
    .margin({ bottom: 12 })
  }
}