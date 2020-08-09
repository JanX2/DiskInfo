/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Cocoa


@IBDesignable class GraphView: NSView {
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    NSColor.white.setFill()
    bounds.fill()
  }
  
  var fileDistribution: FilesDistribution? {
    didSet {
      needsDisplay = true
    }
  }
  
  override func prepareForInterfaceBuilder() {
    let used = Int64(100000000000)
    let available = used / 3
    let filesBytes = used / 5
    let distribution: [FileType] = [
      .apps(bytes: filesBytes / 2, percent: 0.1),
      .photos(bytes: filesBytes, percent: 0.2),
      .movies(bytes: filesBytes * 2, percent: 0.15),
      .audio(bytes: filesBytes, percent: 0.18),
      .other(bytes: filesBytes, percent: 0.2)
    ]
    fileDistribution = FilesDistribution(capacity: used + available,
                                         available: available,
                                         distribution: distribution)
  }
  
  // 1
  fileprivate struct Constants {
    static let barHeight: CGFloat = 30.0
    static let barMinHeight: CGFloat = 20.0
    static let barMaxHeight: CGFloat = 40.0
    static let marginSize: CGFloat = 20.0
    static let pieChartWidthPercentage: CGFloat = 1.0 / 3.0
    static let pieChartBorderWidth: CGFloat = 1.0
    static let pieChartMinRadius: CGFloat = 30.0
    static let pieChartGradientAngle: CGFloat = 90.0
    static let barChartCornerRadius: CGFloat = 4.0
    static let barChartLegendSquareSize: CGFloat = 8.0
    static let legendTextMargin: CGFloat = 5.0
  }
  
  // 2
  @IBInspectable var barHeight: CGFloat = Constants.barHeight {
    didSet {
      barHeight = max(min(barHeight, Constants.barMaxHeight), Constants.barMinHeight)
    }
  }
  @IBInspectable var pieChartUsedLineColor: NSColor = NSColor.pieChartUsedStrokeColor
  @IBInspectable var pieChartAvailableLineColor: NSColor = NSColor.pieChartAvailableStrokeColor
  @IBInspectable var pieChartAvailableFillColor: NSColor = NSColor.pieChartAvailableFillColor
  @IBInspectable var pieChartGradientStartColor: NSColor = NSColor.pieChartGradientStartColor
  @IBInspectable var pieChartGradientEndColor: NSColor = NSColor.pieChartGradientEndColor
  @IBInspectable var barChartAvailableLineColor: NSColor = NSColor.availableStrokeColor
  @IBInspectable var barChartAvailableFillColor: NSColor = NSColor.availableFillColor
  @IBInspectable var barChartAppsLineColor: NSColor = NSColor.appsStrokeColor
  @IBInspectable var barChartAppsFillColor: NSColor = NSColor.appsFillColor
  @IBInspectable var barChartMoviesLineColor: NSColor = NSColor.moviesStrokeColor
  @IBInspectable var barChartMoviesFillColor: NSColor = NSColor.moviesFillColor
  @IBInspectable var barChartPhotosLineColor: NSColor = NSColor.photosStrokeColor
  @IBInspectable var barChartPhotosFillColor: NSColor = NSColor.photosFillColor
  @IBInspectable var barChartAudioLineColor: NSColor = NSColor.audioStrokeColor
  @IBInspectable var barChartAudioFillColor: NSColor = NSColor.audioFillColor
  @IBInspectable var barChartOthersLineColor: NSColor = NSColor.othersStrokeColor
  @IBInspectable var barChartOthersFillColor: NSColor = NSColor.othersFillColor
  
  // 3
  func colorsForFileType(_ fileType: FileType) -> (strokeColor: NSColor, fillColor: NSColor) {
    switch fileType {
    case .audio(_, _):
      return (strokeColor: barChartAudioLineColor, fillColor: barChartAudioFillColor)
    case .movies(_, _):
      return (strokeColor: barChartMoviesLineColor, fillColor: barChartMoviesFillColor)
    case .photos(_, _):
      return (strokeColor: barChartPhotosLineColor, fillColor: barChartPhotosFillColor)
    case .apps(_, _):
      return (strokeColor: barChartAppsLineColor, fillColor: barChartAppsFillColor)
    case .other(_, _):
      return (strokeColor: barChartOthersLineColor, fillColor: barChartOthersFillColor)
    }
  }
}

// MARK: - Drawing extension

extension GraphView {
  func drawRoundedRect(_ rect: CGRect, inContext context: CGContext?,
                       radius: CGFloat, borderColor: CGColor, fillColor: CGColor) {
    // 1
    let path = CGMutablePath()
    
    // 2
    path.move( to: CGPoint(x:  rect.midX, y:rect.minY ))
    path.addArc( tangent1End: CGPoint(x: rect.maxX, y: rect.minY ),
                 tangent2End: CGPoint(x: rect.maxX, y: rect.maxY), radius: radius)
    path.addArc( tangent1End: CGPoint(x: rect.maxX, y: rect.maxY ),
                 tangent2End: CGPoint(x: rect.minX, y: rect.maxY), radius: radius)
    path.addArc( tangent1End: CGPoint(x: rect.minX, y: rect.maxY ),
                 tangent2End: CGPoint(x: rect.minX, y: rect.minY), radius: radius)
    path.addArc( tangent1End: CGPoint(x: rect.minX, y: rect.minY ),
                 tangent2End: CGPoint(x: rect.maxX, y: rect.minY), radius: radius)
    path.closeSubpath()
    
    // 3
    context?.setLineWidth(1.0)
    context?.setFillColor(fillColor)
    context?.setStrokeColor(borderColor)
    
    // 4
    context?.addPath(path)
    context?.drawPath(using: .fillStroke)
  }
  
}

// MARK: - Calculations extension

extension GraphView {
  // 1
  func pieChartRectangle() -> CGRect {
    let width = bounds.size.width * Constants.pieChartWidthPercentage - 2 * Constants.marginSize
    let height = bounds.size.height - 2 * Constants.marginSize
    let diameter = max(min(width, height), Constants.pieChartMinRadius)
    let rect = CGRect(x: Constants.marginSize,
                      y: bounds.midY - diameter / 2.0,
                      width: diameter, height: diameter)
    return rect
  }
  
  // 2
  func barChartRectangle() -> CGRect {
    let pieChartRect = pieChartRectangle()
    let width = bounds.size.width - pieChartRect.maxX - 2 * Constants.marginSize
    let rect = CGRect(x: pieChartRect.maxX + Constants.marginSize,
                      y: pieChartRect.midY + Constants.marginSize,
                      width: width, height: barHeight)
    return rect
  }
  
  // 3
  func barChartLegendRectangle() -> CGRect {
    let barchartRect = barChartRectangle()
    let rect = barchartRect.offsetBy(dx: 0.0, dy: -(barchartRect.size.height + Constants.marginSize))
    return rect
  }
}
