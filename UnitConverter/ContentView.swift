import SwiftUI

struct ContentView: View {
    @State private var viewModel = ConverterViewModel()
    @State private var copiedFormat: CoordinateFormat?
    @State private var showingMap = false

    var body: some View {
        NavigationStack {
            Form {
                inputSection
                formatSection
                formattedSection
                outputSection
            }
            .navigationTitle("GPS Converter")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.parsedCoordinate != nil {
                        Button {
                            showingMap = true
                        } label: {
                            Label("Map", systemImage: "map")
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear") {
                        viewModel.reset()
                        copiedFormat = nil
                    }
                    .disabled(viewModel.inputText.isEmpty && viewModel.outputs.isEmpty)
                }
            }
            .fullScreenCover(isPresented: $showingMap) {
                if let coord = viewModel.parsedCoordinate {
                    MapView(coordinate: coord)
                }
            }
        }
    }

    private var inputSection: some View {
        Section("Coordinate") {
            TextField("Enter coordinates (any format)", text: $viewModel.inputText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .onSubmit { viewModel.convert() }

            Button("Convert") {
                viewModel.formatOverridden = false
                viewModel.convert()
            }
            .frame(maxWidth: .infinity)

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
            }
        }
    }

    @ViewBuilder
    private var formatSection: some View {
        if viewModel.detectedFormat != nil || viewModel.formatOverridden {
            Section(viewModel.formatOverridden ? "Input Format" : "Detected: \(viewModel.selectedFormat.rawValue)") {
                Picker("Format", selection: Binding(
                    get: { viewModel.selectedFormat },
                    set: { viewModel.overrideFormat($0) }
                )) {
                    ForEach(CoordinateFormat.allCases) { format in
                        Text(format.rawValue).tag(format)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var formattedSection: some View {
        if let formatted = viewModel.formattedInput {
            Section("Formatted Input") {
                HStack {
                    Text(formatted)
                        .font(.body.monospaced())
                    Spacer()
                    Button {
                        UIPasteboard.general.string = formatted
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .foregroundStyle(Color.accentColor)
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel("Copy formatted input")
                }
            }
        }
    }

    @ViewBuilder
    private var outputSection: some View {
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
                                .foregroundStyle(copiedFormat == row.format ? Color.green : Color.accentColor)
                        }
                        .buttonStyle(.borderless)
                        .accessibilityLabel("Copy \(row.format.rawValue)")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
