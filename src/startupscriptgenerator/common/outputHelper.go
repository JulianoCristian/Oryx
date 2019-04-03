// --------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.
// --------------------------------------------------------------------------------------------

package common

import (
	"os/exec"
	"strings"
)

func ExtractZippedOutput(srcFolder string, destFolder string) {
	zipFileName := "oryx_output.tar.gz"
	scriptPath := "/tmp/test.sh"
	scriptBuilder := strings.Builder{}
	scriptBuilder.WriteString("#!/bin/sh\n")
	scriptBuilder.WriteString("set -e\n\n")
	scriptBuilder.WriteString("if [ -d \"" + destFolder + "\" ]; then\n")
	scriptBuilder.WriteString("    rm -rf \"" + destFolder + "\"\n")
	scriptBuilder.WriteString("fi\n")
	scriptBuilder.WriteString("mkdir -p \"" + destFolder + "\"\n")
	scriptBuilder.WriteString("cp -rf \"" + srcFolder + "\"/* \"" + destFolder + "\"\n")
	scriptBuilder.WriteString("cd \"" + destFolder + "\"\n")
	scriptBuilder.WriteString("if [ -f \"" + zipFileName + "\" ]; then\n")
	scriptBuilder.WriteString("    echo \"Found '" + zipFileName + "', will extract its contents.\"\n")
	scriptBuilder.WriteString("    echo \"Extracting...\"\n")
	scriptBuilder.WriteString("    tar -xzf " + zipFileName + "\n")
	scriptBuilder.WriteString("    echo \"Done.\"\n")
	scriptBuilder.WriteString("fi\n\n")

	WriteScript(scriptPath, scriptBuilder.String())
	cmd := exec.Command("/bin/sh", "-c", scriptPath)
	err := cmd.Run()
	if err != nil {
		panic(err)
	}
}
