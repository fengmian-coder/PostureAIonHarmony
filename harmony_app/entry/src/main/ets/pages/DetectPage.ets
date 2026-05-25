import { router } from '@kit.ArkUI'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { preferences } from '@kit.ArkData'
import { ApiService } from '../services/ApiService'
import { fileIo } from '@kit.CoreFileKit'

@Entry
@Component
struct DetectPage {
  @State hasImage: boolean = false
  @State loading: boolean = false
  @State imageName: string = ''
  @State imageUri: string = ''

  @State baseUrl: string = 'http://192.168.0.199:8000'
  @State errorMessage: string = ''
  @State uploadFilePath: string = ''

  private settingStore: preferences.Preferences | undefined = undefined
  private readonly STORE_NAME: string = 'PostureAISettings'
  private readonly KEY_BASE_URL: string = 'baseUrl'


  aboutToAppear() {
    this.loadBaseUrl()
  }

  loadBaseUrl() {
    try {
      this.settingStore = preferences.getPreferencesSync(getContext(this), {
        name: this.STORE_NAME
      })

      const savedUrl = this.settingStore.getSync(this.KEY_BASE_URL, this.baseUrl) as string
      this.baseUrl = savedUrl
    } catch (error) {
      this.baseUrl = 'http://192.168.0.199:8000'
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

        Text('AI 体态检测')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ left: 12 })
          .layoutWeight(1)

        Text('说明')
          .fontSize(14)
          .fontColor('#00D4FF')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 48, bottom: 12 })

      Scroll() {
        Column() {
          // 图片上传卡片
          Column() {
            Row() {
              Text('图片上传')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .layoutWeight(1)

              Text(this.hasImage ? '已选择' : '未选择')
                .fontSize(12)
                .fontColor(this.hasImage ? '#07120B' : '#00D4FF')
                .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                .backgroundColor(this.hasImage ? '#00E676' : '#102536')
                .borderRadius(14)
            }
            .width('100%')

            // 图片占位区
            Column() {
              if (this.hasImage) {
                Image(this.imageUri)
                  .width('100%')
                  .height(170)
                  .objectFit(ImageFit.Contain)
                  .borderRadius(14)

                Text(this.imageName)
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
                  .margin({ top: 10 })

                Text('图片已选择，下一步可开始 AI 检测')
                  .fontSize(12)
                  .fontColor('#8EA2AE')
                  .margin({ top: 6 })
              } else {
                Text('+')
                  .fontSize(46)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#00E676')

                Text('选择人体照片')
                  .fontSize(17)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
                  .margin({ top: 8 })

                Text('建议上传正面站立、肩部清晰的照片')
                  .fontSize(12)
                  .fontColor('#8EA2AE')
                  .margin({ top: 8 })
              }
            }
            .width('100%')
            .height(230)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .margin({ top: 18 })
            .backgroundColor('#0B111A')
            .borderRadius(20)
            .border({
              width: 1,
              color: this.hasImage ? '#00E676' : '#1F3A4A'
            })

            Button(this.hasImage ? '重新选择图片' : '选择图片')
              .width('100%')
              .height(48)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .backgroundColor('#102536')
              .borderRadius(24)
              .margin({ top: 18 })
              .onClick(() => {
                this.chooseImage()
              })

            Button(this.loading ? 'AI 检测中...' : '开始 AI 检测')
              .width('100%')
              .height(52)
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor('#07120B')
              .backgroundColor(this.hasImage ? '#00E676' : '#35504A')
              .borderRadius(26)
              .margin({ top: 14 })
              .onClick(() => {
                this.startAnalyze()
              })

            if (this.loading) {
              Row() {
                LoadingProgress()
                  .width(24)
                  .height(24)
                  .color('#00E676')

                Text('正在识别人体骨架关键点，请稍候...')
                  .fontSize(13)
                  .fontColor('#B9C7D0')
                  .margin({ left: 10 })
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .margin({ top: 18 })
            }
            if (this.errorMessage !== '') {
              Text('检测失败：' + this.errorMessage)
                .fontSize(13)
                .fontColor('#FF6B6B')
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

          // 检测流程卡片
          Column() {
            Text('检测流程')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .width('100%')
              .margin({ bottom: 14 })

            this.StepItem('1', '选择图片', '从相册中选择一张人体正面照片')
            this.StepItem('2', '上传检测', '调用后端 AI 视觉识别接口')
            this.StepItem('3', '生成结果', '展示骨架图、体态评分与 AI 建议')
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

          // 检测说明卡片
          Column() {
            Text('拍摄建议')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .width('100%')
              .margin({ bottom: 12 })

            Text('1. 尽量选择光线充足、背景简单的照片。')
              .fontSize(14)
              .fontColor('#B9C7D0')
              .lineHeight(24)
              .width('100%')

            Text('2. 人体上半身应完整入镜，左右肩部尽量清晰可见。')
              .fontSize(14)
              .fontColor('#B9C7D0')
              .lineHeight(24)
              .width('100%')

            Text('3. 当前页面先使用模拟选择图片流程，后续会接入真实相册选择和后端检测接口。')
              .fontSize(14)
              .fontColor('#B9C7D0')
              .lineHeight(24)
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

  @Builder
  StepItem(index: string, title: string, desc: string) {
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

  chooseImage() {
    const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions()
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
    photoSelectOptions.maxSelectNumber = 1

    const photoPicker = new photoAccessHelper.PhotoViewPicker()

    photoPicker.select(photoSelectOptions)
      .then((result: photoAccessHelper.PhotoSelectResult) => {
        if (result.photoUris.length > 0) {
          const uri = result.photoUris[0]

          this.imageUri = uri
          this.imageName = '已选择图片'
          this.hasImage = true
          this.errorMessage = ''

          this.copyImageToCache(uri)
        }
      })
      .catch((error: Error) => {
        this.hasImage = false
        this.imageUri = ''
        this.uploadFilePath = ''
        this.imageName = ''
        this.errorMessage = '选择图片失败：' + String(error)
      })
  }

  copyImageToCache(uri: string) {
    try {
      const context = getContext(this)
      const cacheDir = context.cacheDir
      const targetPath = cacheDir + '/posture_upload.jpg'

      const srcFile = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)
      const dstFile = fileIo.openSync(targetPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE)

      const bufferSize = 1024 * 1024
      const buffer = new ArrayBuffer(bufferSize)
      let readLen = 0

      while ((readLen = fileIo.readSync(srcFile.fd, buffer)) > 0) {
        fileIo.writeSync(dstFile.fd, buffer, {
          length: readLen
        })
      }

      fileIo.closeSync(srcFile)
      fileIo.closeSync(dstFile)

      this.uploadFilePath = targetPath
    } catch (error) {
      this.uploadFilePath = ''
      this.errorMessage = '复制图片到缓存失败：' + String(error)
    }
  }

  startAnalyze() {
    if (!this.hasImage) {
      this.errorMessage = '请先选择一张图片'
      return
    }
    if (this.uploadFilePath === '') {
      this.errorMessage = '图片缓存路径为空，请重新选择图片'
      return
    }
    if (this.loading) {
      return
    }

    this.loading = true
    this.errorMessage = ''


    ApiService.analyzeImage(this.baseUrl, this.uploadFilePath)
      .then((result: string) => {
        this.loading = false

        router.pushUrl({
          url: 'pages/ResultPage',
          params: {
            result: result
          }
        })
      })
      .catch((message: string) => {
        this.loading = false
        this.errorMessage = String(message)
      })
  }

}