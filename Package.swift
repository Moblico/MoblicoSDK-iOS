// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(name: "MoblicoSDK",
                      platforms: [.macOS(.v10_13),
                                  .iOS(.v12)],
                                  .watchOS(.v4),
                                  .tvOS(.v11)],
                      products: [.library(name: "MoblicoSDK",
                                          targets: ["MoblicoSDK"])],
                      targets: [.target(name: "MoblicoSDK",
                                        path: "MoblicoSDK",
                                        publicHeadersPath: "")])
