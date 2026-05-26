import { PostureHistoryRecord } from '../services/ApiService'
import { PostureStats } from '../models/PostureModels'

export class HistoryViewModel {
  static getScoreByAngle(angle: number): number {
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

  static calculateStats(list: PostureHistoryRecord[]): PostureStats {
    if (list.length === 0) {
      return {
        avgScoreText: '--',
        avgAngleText: '--',
        riskCountText: '0',
        bestScoreText: '--'
      }
    }

    let totalScore = 0
    let totalAngle = 0
    let riskCount = 0
    let bestScore = 0

    list.forEach((item: PostureHistoryRecord) => {
      const angle = Number(item.tilt_angle)
      const score = HistoryViewModel.getScoreByAngle(angle)

      totalAngle += angle
      totalScore += score

      if (angle > 3) {
        riskCount += 1
      }

      if (score > bestScore) {
        bestScore = score
      }
    })

    return {
      avgScoreText: (totalScore / list.length).toFixed(1),
      avgAngleText: (totalAngle / list.length).toFixed(1),
      riskCountText: riskCount.toString(),
      bestScoreText: bestScore.toString()
    }
  }

  static sortByLatest(list: PostureHistoryRecord[]): PostureHistoryRecord[] {
    return list.slice().sort((a: PostureHistoryRecord, b: PostureHistoryRecord) => {
      return Number(b.id) - Number(a.id)
    })
  }

  static getTrendList(list: PostureHistoryRecord[]): PostureHistoryRecord[] {
    return HistoryViewModel.sortByLatest(list).slice(0, 5).reverse()
  }

  static getAnglePercent(angle: number): number {
    let percent = angle / 8 * 100

    if (percent < 10) {
      percent = 10
    }

    if (percent > 100) {
      percent = 100
    }

    return percent
  }

  static getSummaryAdvice(list: PostureHistoryRecord[]): string {
    if (list.length === 0) {
      return '当前暂无检测记录。完成一次体态检测后，系统会根据历史数据生成趋势分析和改善建议。'
    }

    const stats = HistoryViewModel.calculateStats(list)
    const avgAngle = Number(stats.avgAngleText)

    if (avgAngle > 3) {
      return '历史记录显示你的肩部倾角平均值偏高，建议保持规律拉伸，并减少长时间单肩背包、低头久坐等习惯。'
    }

    return '历史记录显示你的肩部状态整体较好，建议继续保持良好的坐姿和规律运动习惯。'
  }
}