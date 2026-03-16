import SwiftUI

struct PhotoRowView: View {
    let row: PhotoRow
    @StateObject private var viewModel: PhotoRowViewModel

    init(row: PhotoRow, pipeline: ImagePipeline) {
        self.row = row
        _viewModel = StateObject(wrappedValue: PhotoRowViewModel(row: row, pipeline: pipeline))
    }

    var body: some View {
        HStack(spacing: 16) {
            thumbnail

            VStack(alignment: .leading, spacing: 6) {
                Text(row.title)
                    .font(.headline)

                Text(row.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.background.opacity(0.95))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.quaternary, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }

    @ViewBuilder
    private var thumbnail: some View {
        switch viewModel.phase {
        case .idle, .loading:
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.secondary.opacity(0.12))
                ProgressView()
            }
            .frame(width: 72, height: 72)

        case .loaded(let image):
            image
                .resizable()
                .scaledToFill()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

        case .failed:
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.red.opacity(0.12))
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
            }
            .frame(width: 72, height: 72)
        }
    }
}
