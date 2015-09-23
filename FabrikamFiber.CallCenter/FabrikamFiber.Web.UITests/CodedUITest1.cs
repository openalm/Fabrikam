using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using System.Windows.Input;
using System.Windows.Forms;
using System.Drawing;
using Microsoft.VisualStudio.TestTools.UITesting;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Microsoft.VisualStudio.TestTools.UITest.Extension;
using Keyboard = Microsoft.VisualStudio.TestTools.UITesting.Keyboard;


namespace FabrikamFiber.Web.UITests
{
    /// <summary>
    /// Summary description for CodedUITest1
    /// </summary>
    [CodedUITest]
    public class CodedUITest1
    {
        public CodedUITest1()
        {
        }
        
        [TestMethod]
        [DataSource("Microsoft.VisualStudio.TestTools.DataSource.TestCase", "https://fat2015.visualstudio.com/DefaultCollection;Forrester Demos", "3", DataAccessMethod.Sequential)]
        public void Verify_CreateCustomer()
        {
            //BrowserWindow.CurrentBrowser = "Chrome";
            // To generate code for this test, select "Generate Code for Coded UI Test" from the shortcut menu and select one of the menu items.
            this.UIMap.Loadhttp127001100();
            this.UIMap.ClickonCustomerslink();
            this.UIMap.ClickonCreateNewbutton();
            this.UIMap.EntercustomerdetailsFirstNameLastNameStreetCityStateZipParams.UIFirstNameEditText = TestContext.DataRow["firstname"].ToString();
            this.UIMap.EntercustomerdetailsFirstNameLastNameStreetCityStateZipParams.UILastNameEditText = TestContext.DataRow["lastname"].ToString();
            this.UIMap.EntercustomerdetailsFirstNameLastNameStreetCityStateZipParams.UIStreetEditText = TestContext.DataRow["streetname"].ToString();
            this.UIMap.EntercustomerdetailsFirstNameLastNameStreetCityStateZipParams.UICityEditText = TestContext.DataRow["city"].ToString();
            this.UIMap.EntercustomerdetailsFirstNameLastNameStreetCityStateZipParams.UIStateEditText = TestContext.DataRow["state"].ToString();
            this.UIMap.EntercustomerdetailsFirstNameLastNameStreetCityStateZipParams.UIZipEditText = TestContext.DataRow["zip"].ToString();
            this.UIMap.EntercustomerdetailsFirstNameLastNameStreetCityStateZip();
            this.UIMap.ClickCreate();
        }

        #region Additional test attributes

        // You can use the following additional attributes as you write your tests:

        ////Use TestInitialize to run code before running each test 
        //[TestInitialize()]
        //public void MyTestInitialize()
        //{        
        //    // To generate code for this test, select "Generate Code for Coded UI Test" from the shortcut menu and select one of the menu items.
        //}

        ////Use TestCleanup to run code after each test has run
        //[TestCleanup()]
        //public void MyTestCleanup()
        //{        
        //    // To generate code for this test, select "Generate Code for Coded UI Test" from the shortcut menu and select one of the menu items.
        //}

        #endregion

        /// <summary>
        ///Gets or sets the test context which provides
        ///information about and functionality for the current test run.
        ///</summary>
        public TestContext TestContext
        {
            get
            {
                return testContextInstance;
            }
            set
            {
                testContextInstance = value;
            }
        }
        private TestContext testContextInstance;

        public UIMap UIMap
        {
            get
            {
                if ((this.map == null))
                {
                    this.map = new UIMap();
                }

                return this.map;
            }
        }

        private UIMap map;
    }
}
