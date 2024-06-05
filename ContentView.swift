import SwiftUI

enum VersionType: String, CaseIterable {
    case beta = "Beta"
    case release = "Release"
}

enum Architecture: String, CaseIterable {
    case arm64
    case arm64e
}

struct ContentView: View {
    @State private var selectedVersionType = VersionType.release
    @State private var selectedArchitecture = Architecture.arm64
    @State private var iOSVersion = ""
    @State private var isSupported = false
    @State private var supportedRange: String? = nil
    @State private var supportedLinks: [String: String]? = nil
    
     let trollStoreSupportData: [TrollStoreSupportData] = [
        TrollStoreSupportData(fromVersion: "14.0 beta 1 and earlier", toVersion: "14.0 beta 2", platforms: "arm64 (A8) - arm64 (A9-A11)", supported: [:]),
        TrollStoreSupportData(fromVersion: "14.0 beta 2", toVersion: "14.8.1", platforms: "arm64 (A8) - arm64 (A9-A11)", supported: ["TrollInstallerX": "https://ios.cfw.guide/installing-trollstore-trollinstallerx", "TrollHelperOTA": "https://ios.cfw.guide/installing-trollstore-trollhelperota"]),
        TrollStoreSupportData(fromVersion: "15.0", toVersion: "15.0", platforms: "arm64 (A8) - arm64e (A12-A17/M1-M2)", supported: ["TrollInstallerX": "https://ios.cfw.guide/installing-trollstore-trollinstallerx", "TrollHelperOTA": "https://ios.cfw.guide/installing-trollstore-trollhelperota"]),
        TrollStoreSupportData(fromVersion: "15.0 beta 1", toVersion: "15.5 beta 4", platforms: "arm64 (A8) - arm64e (A12-A17/M1-M2)", supported: ["TrollHelperOTA": "https://ios.cfw.guide/installing-trollstore-trollhelperota"]),
        TrollStoreSupportData(fromVersion: "15.5", toVersion: "15.5", platforms: "arm64 (A8) - arm64e (A12-A17/M1-M2)", supported: ["TrollInstallerMDC": "https://ios.cfw.guide/installing-trollstore-trollinstallermdc", "TrollInstallerX": "https://ios.cfw.guide/installing-trollstore-trollinstallerx", "TrollHelperOTA": "https://ios.cfw.guide/installing-trollstore-trollhelperota"]),
        TrollStoreSupportData(fromVersion: "16.0 beta 1", toVersion: "16.0 beta 3", platforms: "arm64 (A8) - arm64e (A12-A17/M1-M2)", supported: [:]),
    TrollStoreSupportData(fromVersion: "16.0 beta 4", toVersion: "16.6.1", platforms: "arm64 (A8) - arm64e (A12-A17/M1-M2)", supported: ["TrollInstallerX": "https://ios.cfw.guide/installing-trollstore-trollinstallerx", "TrollHelperOTA": "https://ios.cfw.guide/installing-trollstore-trollhelperota"]),
    TrollStoreSupportData(fromVersion: "16.7 RC", toVersion: "16.7 RC", platforms: "arm64 (A8) - arm64e (A12-A17/M1-M2)", supported: ["TrollHelper": "https://ios.cfw.guide/installing-trollstore-trollhelper", "No Install Method": ""]),
    TrollStoreSupportData(fromVersion: "16.7", toVersion: "16.7.7", platforms: "arm64 (A8) - arm64e (A12-A17/M1-M2)", supported: ["Unsupported": ""]),
    TrollStoreSupportData(fromVersion: "17.0 beta 1", toVersion: "17.0 beta 4", platforms: "arm64 (A8) - arm64e (A12-A17/M1-M2)", supported: ["TrollInstallerX": "https://ios.cfw.guide/installing-trollstore-trollinstallerx", "No Install Method": ""]),
    TrollStoreSupportData(fromVersion: "17.0 beta 5", toVersion: "17.0", platforms: "arm64 (A8) - arm64e (A12-A17/M1-M2)", supported: ["TrollHelper": "https://ios.cfw.guide/installing-trollstore-trollhelper", "No Install Method": ""]),
    TrollStoreSupportData(fromVersion: "17.0.1 and later", toVersion: "17.0.1 and later", platforms: "arm64 (A8) - arm64e (A12-A17/M1-M2)", supported: ["Unsupported": ""])
    ]
    
    var body: some View {
        VStack {
            HStack {
                Picker("Version Type", selection: $selectedVersionType) {
                    ForEach(VersionType.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Picker("Architecture", selection: $selectedArchitecture) {
                    ForEach(Architecture.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
            }
            
            TextField("Type Your iOS Version", text: $iOSVersion)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("Check") {
                let result = trollStoreSupportInfo(for: iOSVersion)
                isSupported = result.supported
                supportedRange = result.supportedRange
                supportedLinks = result.supportedLinks
            }
            .padding()
            
            if isSupported {
                Text("iOS Version: \(iOSVersion)")
                    .padding()
                Text("TrollStore Support: Supported")
                    .padding()
                    .foregroundColor(.green)
                if let range = supportedRange {
                    Text(range)
                        .padding()
                }
                if let links = supportedLinks {
                    ForEach(links.sorted(by: <), id: \.key) { platform, link in
                        Button("\(platform) Go to Install Guide") {
                            guard let url = URL(string: link) else { return }
                            UIApplication.shared.open(url)
                        }
                        .padding()
                    }
                }
            } else {
                Text("iOS Version: \(iOSVersion)")
                    .padding()
                Text("TrollStore Supported: Unsupported")
                    .padding()
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
    
    func trollStoreSupportInfo(for iOSVersion: String) -> (supported: Bool, supportedRange: String?, supportedLinks: [String: String]?) {
        let version = selectedVersionType == .beta ? "\(iOSVersion) \(selectedVersionType.rawValue)" : iOSVersion
        let architecture = selectedArchitecture.rawValue
        
        for data in trollStoreSupportData {
            if version >= data.fromVersion && version <= data.toVersion {
                if let supportedPlatforms = data.supported[architecture] {
                    return (true, "Supported platforms: \(supportedPlatforms), Full Range: \(data.fromVersion) - \(data.toVersion)", data.supported)
                } else {
                    return (false, nil, nil)
                }
            }
        }
        return (false, nil, nil)
    }
}

struct TrollStoreSupportData {
    let fromVersion: String
    let toVersion: String
    let platforms: String
    let supported: [String: String] 
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
