from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

def add_to_cart(item_name):
    options = Options()
    options.add_argument(r"user-data-dir=C:\Users\bhumu\AppData\Local\Google\Chrome\User Data\amazon_profile")
    
    driver = webdriver.Chrome(options=options)
    try:
        driver.get("https://www.amazon.in/")
        searchbox = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.ID, "twotabsearchtextbox")))
        searchbox.send_keys(item_name)
        searchbox.send_keys(Keys.RETURN)
        
        # Click first product
        first_result = WebDriverWait(driver, 10).until(EC.element_to_be_clickable((By.XPATH, "//div[contains(@class, 's-result-item')]//h2//a")))
        first_result.click()
        
        # Switch to new tab
        driver.switch_to.window(driver.window_handles[-1])
        
        add_button = WebDriverWait(driver, 10).until(EC.element_to_be_clickable((By.ID, "add-to-cart-button")))
        add_button.click()
        
        time.sleep(2)
        driver.quit()
        return f"Added {item_name} to cart!"
    except Exception as e:
        driver.quit()
        return f"Shopping Error: {str(e)}"