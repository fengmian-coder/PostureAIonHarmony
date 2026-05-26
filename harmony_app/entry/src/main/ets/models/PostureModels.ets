export interface PostureStats {
  avgScoreText: string
  avgAngleText: string
  riskCountText: string
  bestScoreText: string
}

export interface LatestPostureResult {
  hasRecord: boolean
  score: number
  angle: number
  diagnosis: string
}

export interface HistoryTrendItem {
  date: string
  angle: number
  percent: number
}