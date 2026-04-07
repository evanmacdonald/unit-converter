import SwiftUI

struct ContentView: View {
    @State private var viewModel = ConverterViewModel()
    @State private var copiedFormat: CoordinateFormat?

    var body: some View {
        NavigationStack {
            Form {
                Section("Input Format") {
                    Picker("Format", selection: $viewModel.selectedFormat) {
                        ForEach(CoordinateFormat.allCases) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Coordinate") {
                    TextField("Enter \(viewModel.selectedFormat.rawValue) coordinate", text: $viewModel.inputText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                if !viewModel.outputs.isEmpty {
                    Section("Converted") {
                        ForEach(viewModel.outputs) { row in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(row.format.rawValue)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(row.value)
                                        .font(.body.monospaced())
                                }
                                Spacer()
                                Button {
                                    UIPasteboard.general.string = row.value
                                    copiedFormat = row.format
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        if copiedFormat == row.format {
                                            copiedFormat = nil
                                        }
                                    }
                                } label: {
                                    Image(systemName: copiedFormat == row.format ? "checkmark" : "doc.on.doc")
                                        .foregroundStyle(copiedFormat == row.format ? .green : .accentColor)
                                }
                                .buttonStyle(.borderless)
                                .accessibilityLabel("Copy \(row.format.rawValue)")
                            }
                        }
                    }
                }
            }
            .navigationTitle("GPS Converter")
        }
    }
}

#Preview {
    ContentView()
}
