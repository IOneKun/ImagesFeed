import XCTest

final class ImagesFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    func testAuth() throws {
        
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 7))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("ivan.kuninets@yandex.ru")
        print(app.keyboards.debugDescription)
        app.buttons["Done"].tap()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        
        passwordTextField.tap()
        passwordTextField.typeText("19011997")
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        let app = XCUIApplication()
        
        let table = app.tables.element(boundBy: 0)
        XCTAssertTrue(table.waitForExistence(timeout: 5), "Таблица не появилась")

        table.swipeUp()
        sleep(2)

        let cellToLike = table.cells.element(boundBy: 1)
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 5), "Ячейка №2 не найдена")

 
        let likeButtonOff = cellToLike.buttons["like button off"]
        XCTAssertTrue(likeButtonOff.waitForExistence(timeout: 3), "Кнопка 'like button off' не найдена")
        likeButtonOff.tap()

        // Нажимаем кнопку лайка, когда она включена
        let likeButtonOn = cellToLike.buttons["like button on"]
        XCTAssertTrue(likeButtonOn.waitForExistence(timeout: 3), "Кнопка 'like button on' не найдена")
        likeButtonOn.tap()

        sleep(2)

       
        cellToLike.tap()
        sleep(2)

        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5), "Изображение не найдено")


        image.pinch(withScale: 3, velocity: 1)   // zoom in
        image.pinch(withScale: 0.5, velocity: -1) // zoom out

        let backButton = app.buttons["nav back button white"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Кнопка назад не найдена")
        backButton.tap()
    }

    
    func testProfile() throws {
            sleep(3)
            app.tabBars.buttons.element(boundBy: 1).tap()
           
            XCTAssertTrue(app.staticTexts["Name Lastname"].exists)
            XCTAssertTrue(app.staticTexts["@username"].exists)
            
            app.buttons["logout button"].tap()
            
            app.alerts["Bye bye!"].scrollViews.otherElements.buttons["Yes"].tap()
        }
}
