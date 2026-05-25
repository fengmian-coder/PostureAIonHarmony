import { http } from '@kit.NetworkKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { fileIo } from '@kit.CoreFileKit'
import { util } from '@kit.ArkTS'
export class PostureHistoryRecord {
  id: number
  filename: string
  tilt_angle: number
  diagnosis: string
  ai_advice: string
  test_time: string

  constructor(
    id: number,
    filename: string,
    tilt_angle: number,
    diagnosis: string,
    ai_advice: string,
    test_time: string
  ) {
    this.id = id
    this.filename = filename
    this.tilt_angle = tilt_angle
    this.diagnosis = diagnosis
    this.ai_advice = ai_advice
    this.test_time = test_time
  }
}

interface HistoryApiItem {
  id: number
  filename: string
  tilt_angle: number
  diagnosis: string
  ai_advice: string
  test_time: string
}

interface HistoryResponse {
  status: string
  data: HistoryApiItem[]
}

export class ApiService {
  static formatBaseUrl(baseUrl: string): string {
    let url = baseUrl.trim()

    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1)
    }

    return url
  }

  static getHealth(baseUrl: string): Promise<boolean> {
    return new Promise((resolve: (value: boolean) => void) => {
      if (baseUrl.trim() === '') {
        resolve(false)
        return
      }

      if (baseUrl.indexOf('http://') !== 0 && baseUrl.indexOf('https://') !== 0) {
        resolve(false)
        return
      }

      const requestUrl = ApiService.formatBaseUrl(baseUrl) + '/health'
      const httpRequest = http.createHttp()

      httpRequest.request(
        requestUrl,
        {
          method: http.RequestMethod.GET,
          readTimeout: 5000,
          connectTimeout: 5000
        },
        (error: BusinessError, data: http.HttpResponse) => {
          httpRequest.destroy()

          if (error) {
            resolve(false)
            return
          }

          resolve(data.responseCode === 200)
        }
      )
    })
  }

  static getHistory(baseUrl: string): Promise<PostureHistoryRecord[]> {
    return new Promise((resolve: (value: PostureHistoryRecord[]) => void, reject: (reason?: string) => void) => {
      if (baseUrl.trim() === '') {
        reject('后端地址为空')
        return
      }

      if (baseUrl.indexOf('http://') !== 0 && baseUrl.indexOf('https://') !== 0) {
        reject('后端地址格式错误')
        return
      }

      const requestUrl = ApiService.formatBaseUrl(baseUrl) + '/history'
      const httpRequest = http.createHttp()

      httpRequest.request(
        requestUrl,
        {
          method: http.RequestMethod.GET,
          readTimeout: 5000,
          connectTimeout: 5000
        },
        (error: BusinessError, data: http.HttpResponse) => {
          httpRequest.destroy()

          if (error) {
            reject('请求失败')
            return
          }

          if (data.responseCode !== 200) {
            reject('状态码异常：' + data.responseCode)
            return
          }

          try {
            const resultText = data.result as string
            const result = JSON.parse(resultText) as HistoryResponse

            if (result.status !== 'success') {
              reject('后端返回失败')
              return
            }

            const list: PostureHistoryRecord[] = result.data.map((item: HistoryApiItem) => {
              return new PostureHistoryRecord(
                Number(item.id),
                String(item.filename),
                Number(item.tilt_angle),
                String(item.diagnosis),
                String(item.ai_advice),
                String(item.test_time)
              )
            })

            resolve(list)
          } catch (e) {
            reject('数据解析失败')
          }
        }
      )
    })
  }


  static analyzeImage(baseUrl: string, imagePath: string): Promise<string> {
    return new Promise((resolve: (value: string) => void, reject: (reason?: string) => void) => {
      if (baseUrl.trim() === '') {
        reject('后端地址为空')
        return
      }

      if (imagePath.trim() === '') {
        reject('图片路径为空')
        return
      }

      if (baseUrl.indexOf('http://') !== 0 && baseUrl.indexOf('https://') !== 0) {
        reject('后端地址格式错误')
        return
      }

      try {
        const file = fileIo.openSync(imagePath, fileIo.OpenMode.READ_ONLY)
        const stat = fileIo.statSync(imagePath)
        const buffer = new ArrayBuffer(stat.size)

        fileIo.readSync(file.fd, buffer)
        fileIo.closeSync(file)

        const uint8Array = new Uint8Array(buffer)
        const base64Helper = new util.Base64Helper()
        const imageBase64 = base64Helper.encodeToStringSync(uint8Array)

        const requestUrl = ApiService.formatBaseUrl(baseUrl) + '/analyze_image'
        const httpRequest = http.createHttp()

        const requestBody = JSON.stringify({
          filename: 'posture_upload.jpg',
          image_base64: imageBase64
        })

        httpRequest.request(
          requestUrl,
          {
            method: http.RequestMethod.POST,
            header: {
              'Content-Type': 'application/json'
            },
            extraData: requestBody,
            readTimeout: 60000,
            connectTimeout: 60000
          },
          (error: BusinessError, data: http.HttpResponse) => {
            httpRequest.destroy()

            if (error) {
              reject('上传失败：' + JSON.stringify(error))
              return
            }

            if (data.responseCode !== 200) {
              reject('状态码异常：' + data.responseCode)
              return
            }

            try {
              const resultText = String(data.result)
              const result = JSON.parse(resultText) as Record<string, Object>

              if (String(result['status']) !== 'success') {
                reject(String(result['message'] || '后端检测失败'))
                return
              }

              resolve(resultText)
            } catch (e) {
              reject('结果解析失败：' + String(e))
            }
          }
        )
      } catch (error) {
        reject('读取图片失败：' + String(error))
      }
    })
  }

  static deleteHistory(baseUrl: string, recordId: number): Promise<boolean> {
    return new Promise((resolve: (value: boolean) => void, reject: (reason?: string) => void) => {
      if (baseUrl.trim() === '') {
        reject('后端地址为空')
        return
      }

      if (recordId <= 0) {
        reject('记录 ID 无效')
        return
      }

      const requestUrl = ApiService.formatBaseUrl(baseUrl) + '/history/' + recordId.toString()
      const httpRequest = http.createHttp()

      httpRequest.request(
        requestUrl,
        {
          method: http.RequestMethod.DELETE,
          readTimeout: 10000,
          connectTimeout: 10000
        },
        (error: BusinessError, data: http.HttpResponse) => {
          httpRequest.destroy()

          if (error) {
            reject('删除失败：' + JSON.stringify(error))
            return
          }

          if (data.responseCode !== 200) {
            reject('状态码异常：' + data.responseCode)
            return
          }

          try {
            const resultText = String(data.result)
            const result = JSON.parse(resultText) as Record<string, Object>

            if (String(result['status']) === 'success') {
              resolve(true)
            } else {
              reject(String(result['message'] || '删除失败'))
            }
          } catch (e) {
            reject('数据解析失败：' + String(e))
          }
        }
      )
    })
  }

  static clearHistory(baseUrl: string): Promise<boolean> {
    return new Promise((resolve: (value: boolean) => void, reject: (reason?: string) => void) => {
      if (baseUrl.trim() === '') {
        reject('后端地址为空')
        return
      }

      const requestUrl = ApiService.formatBaseUrl(baseUrl) + '/history/clear'
      const httpRequest = http.createHttp()

      httpRequest.request(
        requestUrl,
        {
          method: http.RequestMethod.DELETE,
          readTimeout: 10000,
          connectTimeout: 10000
        },
        (error: BusinessError, data: http.HttpResponse) => {
          httpRequest.destroy()

          if (error) {
            reject('清空失败：' + JSON.stringify(error))
            return
          }

          if (data.responseCode !== 200) {
            reject('状态码异常：' + data.responseCode)
            return
          }

          try {
            const resultText = String(data.result)
            const result = JSON.parse(resultText) as Record<string, Object>

            if (String(result['status']) === 'success') {
              resolve(true)
            } else {
              reject(String(result['message'] || '清空失败'))
            }
          } catch (e) {
            reject('数据解析失败：' + String(e))
          }
        }
      )
    })
  }

}