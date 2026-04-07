import SwiftUI

struct ContentView: View {
    @State private var viewModel = ConverterViewModel()
    @State private var copiedFormat: CoordinateFormat?

    var body: some View {
        NavigationStack {
            Form {
                Section("Coordinate") {
                    TextField("Enter coordinates (any format)", text: $viewModel.inputText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onChange(of: viewModel.inputText) {
                            viewModel.inputChanged()
                        }
                        .onSubmit { viewModel.convert() }

                    Button("Convert") {
                        viewModel.convert()
                    }
                    .frame(maxWidth: .infinity)

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }

                if viewModel.detectedFormat != nil || viewModel.formatOverridden {
                    Section {
                        Picker("Format", selection: Binding(
                            get: { viewModel.selectedFormat },
                            set: { viewModel.overrideFormat($0) }
                        )) {
                            ForEach(CoordinateFormat.allCases) { format in
                                Text(format.rawValue).tag(format)
                            }
                        }
                    } header: {
                        if let detected = viewModel.detectedFormat, !viewModel.formatOverridden {
                            Text("Detected: \(detected.rawValue)")
                        } else {
                            Text("Input Format")
                        }
                    }

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
                                        .foregroundStyle(.accentColor)
                                }
                                .buttonStyle(.borderless)
                                .accessibilityLabel("Copy formatted input")
                            }
                        }
                    }
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
