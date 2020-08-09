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
  
}
