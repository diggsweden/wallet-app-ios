import SwiftUI

enum BrandColors {
  static let green = ColorScale(
    `10`: Color.rgba(238, 240, 238),
    `25`: Color.rgba(213, 218, 212),
    `50`: Color.rgba(171, 181, 169),
    `70`: Color.rgba(135, 149, 133),
    `100`: Color.rgba(85, 105, 81),
    `130`: Color.rgba(60, 74, 57),
    `150`: Color.rgba(43, 53, 41),
    `175`: Color.rgba(21, 26, 20)
  )

  static let pink = ColorScale(
    `10`: Color.rgba(251, 242, 240),
    `25`: Color.rgba(243, 222, 219),
    `50`: Color.rgba(230, 189, 184),
    `70`: Color.rgba(220, 162, 155),
    `100`: Color.rgba(205, 121, 109),
    `130`: Color.rgba(143, 85, 76),
    `150`: Color.rgba(103, 61, 55),
    `175`: Color.rgba(51, 30, 27)
  )

  static let yellow = ColorScale(
    `10`: Color.rgba(250, 242, 235),
    `25`: Color.rgba(243, 223, 205),
    `50`: Color.rgba(231, 192, 155),
    `70`: Color.rgba(222, 166, 115),
    `100`: Color.rgba(206, 128, 52),
    `130`: Color.rgba(144, 90, 36),
    `150`: Color.rgba(103, 64, 26),
    `175`: Color.rgba(52, 32, 13),
  )

  static let neutral = ColorScale(
    `10`: Color.rgba(232, 232, 232),
    `25`: Color.rgba(195, 195, 194),
    `50`: Color.rgba(148, 148, 148),
    `70`: Color.rgba(116, 115, 114),
    `100`: Color.rgba(43, 42, 41),
    `130`: Color.rgba(30, 29, 27),
    `150`: Color.rgba(30, 29, 27),
    `175`: Color.rgba(30, 29, 27),
  )
}
