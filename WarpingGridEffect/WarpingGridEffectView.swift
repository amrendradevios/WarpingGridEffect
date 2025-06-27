//
//  WarpingGridEffectView.swift
//  WarpingGridEffect
//
//  Created by APS on 27/06/25.
//

import SwiftUI

/// A view that displays an interactive warping grid that responds to finger movement with spring animation.
public struct WarpingGridEffectView: View {

    /// Stores the user's current touch location.
    @State private var touchLocation: CGPoint? = nil

    /// Desired number of rows and columns in the grid.
    private let desiredRows: Int
    private let desiredCols: Int

    public init(desiredRows: Int = 35, desiredCols: Int = 20) {
        self.desiredRows = desiredRows
        self.desiredCols = desiredCols
    }

    public var body: some View {
        GeometryReader { geometry in
            // Calculate grid spacing dynamically based on screen size
            let size = geometry.size
            let spacingY = size.height / CGFloat(desiredRows)
            let spacingX = size.width / CGFloat(desiredCols)
            // Draw the animated grid
            Canvas { context, _ in
                drawGrid(context: context, spacingX: spacingX, spacingY: spacingY)
            }
            .gesture(gridDragGesture)
            .background(Color.black)
        }
    }

    /// Draws the grid lines based on calculated spacing.
    private func drawGrid(context: GraphicsContext, spacingX: CGFloat, spacingY: CGFloat) {
        for row in 0...desiredRows {
            for col in 0...desiredCols {
                let point = CGPoint(x: CGFloat(col) * spacingX, y: CGFloat(row) * spacingY)
                let warped = warp(point: point)

                // Vertical lines
                if col < desiredCols {
                    let nextX = CGPoint(x: CGFloat(col + 1) * spacingX, y: CGFloat(row) * spacingY)
                    let nextWarpedX = warp(point: nextX)
                    drawLine(from: warped, to: nextWarpedX, in: context)
                }

                // Horizontal lines
                if row < desiredRows {
                    let nextY = CGPoint(x: CGFloat(col) * spacingX, y: CGFloat(row + 1) * spacingY)
                    let nextWarpedY = warp(point: nextY)
                    drawLine(from: warped, to: nextWarpedY, in: context)
                }
            }
        }
    }

    /// Draws a line between two points on the canvas.
    private func drawLine(from start: CGPoint, to end: CGPoint, in context: GraphicsContext) {
        var path = Path()
        path.move(to: start)
        path.addLine(to: end)
        context.stroke(path, with: .color(.white), lineWidth: 1)
    }

    /// Applies a spring-based warp transformation to a grid point based on the user's touch.
    private func warp(point: CGPoint) -> CGPoint {
        guard let touch = touchLocation else { return point }

        let maxDistance: CGFloat = 200
        let distance = hypot(point.x - touch.x, point.y - touch.y)
        guard distance < maxDistance else { return point }

        let angle = atan2(point.y - touch.y, point.x - touch.x)
        let force = (maxDistance - distance) / maxDistance * 30
        let dx = cos(angle) * force
        let dy = sin(angle) * force

        return CGPoint(x: point.x + dx, y: point.y + dy)
    }

    /// Gesture that updates the touch location and triggers animations.
    private var gridDragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    touchLocation = value.location
                }
            }
            .onEnded { _ in
                withAnimation(.easeOut(duration: 0.5)) {
                    touchLocation = nil
                }
            }
    }
}
