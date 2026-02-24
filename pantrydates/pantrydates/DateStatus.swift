// Copyright Justin Bishop, 2026

import SwiftUI

func isExpired(_ date: Date) -> Bool {
  isPastExpired(date) || Calendar.current.isDateInToday(date)
}

func isPastExpired(_ date: Date) -> Bool {
  date < Calendar.current.startOfDay(for: Date())
}

func isExpiringSoon(_ date: Date) -> Bool {
  guard !isExpired(date) else { return false }
  let calendar = Calendar.current
  let today = calendar.startOfDay(for: Date())
  guard
    let oneWeekFromNow = calendar.date(
      byAdding: .day,
      value: 7,
      to: today
    )
  else {
    return false
  }
  return date < oneWeekFromNow
}

func dateColor(for date: Date) -> Color {
  if isExpired(date) {
    return .red
  } else if isExpiringSoon(date) {
    return .yellow
  } else {
    return .secondary
  }
}
