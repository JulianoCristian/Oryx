﻿// --------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.
// --------------------------------------------------------------------------------------------

using System.IO;
using System.Threading.Tasks;
using Xunit;
using Xunit.Abstractions;

namespace Microsoft.Oryx.Integration.Tests.LocalDockerTests
{
    public class MySqlIntegrationTests : DatabaseTestsBase, IClassFixture<Fixtures.MySqlDbContainerFixture>
    {
        public MySqlIntegrationTests(ITestOutputHelper output, Fixtures.MySqlDbContainerFixture dbFixture)
            : base(output, dbFixture)
        {
        }

        [Fact(Skip = "Bug 832951")]
        public async Task NodeApp_MySqlDB()
        {
            await RunTestAsync("nodejs",  "10.14", Path.Combine(HostSamplesDir, "nodejs", "node-mysql"));
        }

        [Theory(Skip = "Bug 832951")]
        [InlineData("mysql-pymysql-sample")]
        [InlineData("mysql-mysqlconnector-sample")]
        [InlineData("mysql-mysqlclient-sample")]
        public async Task Python37App_MySqlDB_UsingPyMySql(string sampleAppName)
        {
            await RunTestAsync("python", "3.7", Path.Combine(HostSamplesDir, "python", sampleAppName));
        }

        [Theory(Skip = "Bug 832951")]
        [InlineData("7.3")]
        [InlineData("7.2")]
        [InlineData("7.0")]
        [InlineData("5.6")]
        public async Task PhpApp_UsingMysqli(string phpVersion)
        {
            await RunTestAsync("php", phpVersion, Path.Combine(HostSamplesDir, "php", "mysqli-example"), 80,
                specifyBindPortFlag: false);
        }
    }
}