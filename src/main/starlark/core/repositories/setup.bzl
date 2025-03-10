# Copyright 2020 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load("@rules_proto//proto:repositories.bzl", "rules_proto_dependencies", "rules_proto_toolchains")
load("@rules_jvm_external//:defs.bzl", "maven_install")
load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")
load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")
load("@build_bazel_rules_android//android:rules.bzl", "android_sdk_repository")
load("//src/main/starlark/core/repositories:versions.bzl", "versions")
load("@rules_pkg//:deps.bzl", "rules_pkg_dependencies")

# Workaround for https://github.com/bazelbuild/rules_proto/commit/f371ed34ed7f1a8b83cc34ae96db277e0ba4fcb0
load("@rules_proto//proto/private:dependencies.bzl", "maven_dependencies")
load("@bazel_tools//tools/build_defs/repo:java.bzl", "java_import_external")

CORRECTED_RULES_PROTO_SHAS = {
    # bad -> good
    "ad275e75ee79e6c6388198dcb9acf0db2edee64782e11b508f379c3a2a17d168": "51febfb24af6faa7eb729c880b8ba011cbab8ce55920656a450740b73d343ee2",
    "0b16133638b1455bea3449c002c7769c75962007d55e9a39c0bed55128da7f70": "34dc0c5bc98416e95a28b3b18caf74816eaa083b2f9c5702b2300a3763970c7b",
}

def kt_configure():
    """Setup dependencies. Must be called AFTER kt_download_local_dev_dependencies() """

    # workaround for https://github.com/bazelbuild/rules_proto/commit/f371ed34ed7f1a8b83cc34ae96db277e0ba4fcb0
    for (name, arguments) in maven_dependencies.items():
        java_import_external(
            name = name,
            **{
                n: CORRECTED_RULES_PROTO_SHAS.get(str(a), a)
                for n, a in arguments.items()
            }
        )

    maven_install(
        name = "kotlin_rules_maven",
        fetch_sources = True,
        artifacts = [
            "com.google.code.findbugs:jsr305:3.0.2",
            "junit:junit:4.13-beta-3",
            "com.google.protobuf:protobuf-java:3.6.0",
            "com.google.protobuf:protobuf-java-util:3.6.0",
            "com.google.guava:guava:27.1-jre",
            "com.google.truth:truth:0.45",
            "com.google.auto.service:auto-service:1.0-rc5",
            "com.google.auto.service:auto-service-annotations:1.0-rc5",
            "com.google.auto.value:auto-value:1.6.5",
            "com.google.auto.value:auto-value-annotations:1.6.5",
            "com.google.dagger:dagger:2.43.2",
            "com.google.dagger:dagger-compiler:2.43.2",
            "com.google.dagger:dagger-producers:2.43.2",
            "javax.annotation:javax.annotation-api:1.3.2",
            "javax.inject:javax.inject:1",
            "org.pantsbuild:jarjar:1.7.2",
            "org.jetbrains.kotlinx:atomicfu-js:0.15.2",
            "org.jetbrains.kotlinx:kotlinx-serialization-runtime:1.0-M1-1.4.0-rc",
        ],
        repositories = [
            "https://maven-central.storage.googleapis.com/repos/central/data/",
            "https://maven.google.com",
            "https://repo1.maven.org/maven2",
        ],
    )

    rules_proto_dependencies()
    rules_proto_toolchains()

    rules_pkg_dependencies()

    stardoc_repositories()

    bazel_skylib_workspace()

    android_sdk_repository(name = "androidsdk")

    [
        native.local_repository(
            name = version,
            path = "src/%s" % version,
        )
        for version in versions.CORE
    ]
