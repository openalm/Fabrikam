using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.IE;
using System;
using System.Runtime.CompilerServices;
using System.Text;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Assert = NUnit.Framework.Assert;
using TestContext = Microsoft.VisualStudio.TestTools.UnitTesting.TestContext;
using OpenQA.Selenium.Remote;

namespace FabrikamFiber.Web.PureSeleniumTests
{
    [TestClass]
    public class SeleniumTests
    {
        private IWebDriver driver;
        private StringBuilder verificationErrors;
        private string baseURL;
        private bool acceptNextAlert = true;

        public TestContext TestContext
        {
            get;
            set;
        }


        [TestInitialize]
        public void SetupTest()
        {          
            baseURL = this.TestContext.Properties["webAppUrl"].ToString();            
            verificationErrors = new StringBuilder();
        }

        [TestCleanup]
        public void TeardownTest()
        {
            try
            {   
               driver.Quit();
                driver.Dispose();
            }
            catch (Exception)
            {
                // Ignore errors if unable to close the browser
            }
            Assert.AreEqual("", verificationErrors.ToString());
        }

        [TestMethod]
        [Priority(0)]
        public void Selenium_CreateNewCustomerRecordFireFox()
        {
            CreateRemoteDriver("firefox");
            Selenium_CreateNewCustomerRecord();
        }

        [TestMethod]
        [Priority(0)]
        public void Selenium_CreateNewCustomerRecordChrome()
        {
            CreateRemoteDriver("chrome");
            Selenium_CreateNewCustomerRecord();
        }

        [TestMethod]
        [Priority(0)]
        public void Selenium_VerifyDashboardPageFireFox()
        {
            CreateRemoteDriver("firefox");
            Selenium_VerifyDashboardPage();
        }

        [TestMethod]
        [Priority(0)]
        public void Selenium_VerifyDashboardPageChrome()
        {
            CreateRemoteDriver("chrome");
            Selenium_VerifyDashboardPage();
        }
                
        private void CreateRemoteDriver(string Browser)
        {
            DesiredCapabilities capability = new DesiredCapabilities();
            capability.SetCapability("browserName", Browser);
            Uri server = new Uri (this.TestContext.Properties["hubUrl"].ToString());
            //Uri server = new Uri("http://atinbvsdesktop:4444/wd/hub");

            this.driver = new RemoteWebDriver(server, capability);
            driver.Manage().Window.Maximize();
        }
        private void Selenium_CreateNewCustomerRecord()
        {
            driver.Navigate().GoToUrl(baseURL);
            driver.FindElement(By.LinkText("Customers")).Click();
            System.Threading.Thread.Sleep(500);
            driver.FindElement(By.LinkText("Create New")).Click();
            driver.FindElement(By.Id("FirstName")).Clear();
            driver.FindElement(By.Id("FirstName")).SendKeys("Mary");
            driver.FindElement(By.Id("LastName")).Clear();
            driver.FindElement(By.Id("LastName")).SendKeys("Poppins");
            driver.FindElement(By.Id("Address_Street")).Clear();
            driver.FindElement(By.Id("Address_Street")).SendKeys("1234 Disneyland");
            driver.FindElement(By.Id("Address_City")).Clear();
            driver.FindElement(By.Id("Address_City")).SendKeys("Disney");
            driver.FindElement(By.Id("Address_State")).Clear();
            driver.FindElement(By.Id("Address_State")).SendKeys("LA");
            driver.FindElement(By.Id("Address_Zip")).Clear();
            driver.FindElement(By.Id("Address_Zip")).SendKeys("12345");
            driver.FindElement(By.CssSelector("input.glossyBox")).Click();
        }

        private void Selenium_VerifyDashboardPage()
        {
            driver.Navigate().GoToUrl(baseURL);
            System.Threading.Thread.Sleep(500);
            String pageTitle = driver.FindElement(By.CssSelector("#content h1")).Text.Trim();
            Assert.AreEqual(pageTitle, "Dashboard");
        }

        private void Selenium_VerifyDashboardPage_NavigatesToReport()
        {
            driver.Navigate().GoToUrl(baseURL);
            System.Threading.Thread.Sleep(500);
            //driver.FindElement(By.CssSelector("ul.alerts li a span")).Click();
            driver.FindElement(By.LinkText("Reports")).Click();
            System.Threading.Thread.Sleep(1000);
            String pageTitle = driver.FindElement(By.CssSelector("#content h2")).Text.Trim();
            Assert.AreEqual("Reports", pageTitle,"Expected to be on Alerts page on click of Alerts, but ended up on " + pageTitle +" page.");
        }

        private bool IsElementPresent(By by)
        {
            try
            {
                driver.FindElement(by);
                return true;
            }
            catch (NoSuchElementException)
            {
                return false;
            }
        }

        private bool IsAlertPresent()
        {
            try
            {
                driver.SwitchTo().Alert();
                return true;
            }
            catch (NoAlertPresentException)
            {
                return false;
            }
        }

        private string CloseAlertAndGetItsText()
        {
            try
            {
                IAlert alert = driver.SwitchTo().Alert();
                string alertText = alert.Text;
                if (acceptNextAlert)
                {
                    alert.Accept();
                }
                else
                {
                    alert.Dismiss();
                }
                return alertText;
            }
            finally
            {
                acceptNextAlert = true;
            }
        }

    }
}
