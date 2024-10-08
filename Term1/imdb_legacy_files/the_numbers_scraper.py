import requests
from bs4 import BeautifulSoup
import pandas as pd
import time

# Base URL
base_url = "https://www.the-numbers.com/movie/budgets/all"

# Function to scrape a single page
def scrape_page(url):
    # Set up headers to mimic a web browser
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36'
    }

    response = requests.get(url, headers=headers)

    # Check if the request was successful
    if response.status_code != 200:
        print(f"Failed to retrieve {url} - Status code: {response.status_code}")
        return []

    soup = BeautifulSoup(response.text, 'html.parser')
    
    # Find the table with the movie budget data
    table = soup.find('table')

    # Check if the table exists
    if table is None:
        print(f"No table found at {url}, stopping scraping.")
        return []

    # Get all the rows from the table, skipping the header
    rows = table.find_all('tr')[1:]  # Skip the header row

    # Collect movie budget data
    data = []
    for row in rows:
        cols = row.find_all('td')
        cols = [ele.text.strip() for ele in cols]
        data.append(cols)
    
    return data

# Main function to scrape all pages
def scrape_all_pages():
    all_data = []
    offset = 0
    
    while True:
        # Create URL for the current page
        if offset == 0:
            url = base_url
        else:
            url = f"{base_url}/{offset + 1}"
        
        print(f"Scraping page: {url}")
        
        # Scrape the current page
        data = scrape_page(url)
        
        # If no data is returned, stop the loop
        if not data:
            print("No more data to scrape, exiting.")
            break
        
        all_data.extend(data)
        
        # Increment the offset by 100 for the next page
        offset += 100
        
        # Respectful delay to avoid overloading the server
        time.sleep(1)
    
    return all_data

# Scrape data from all pages and store it in a CSV
def main():
    print("Starting to scrape movie budget data...")
    all_movie_data = scrape_all_pages()
    
    if all_movie_data:
        # Convert to a pandas DataFrame
        columns = ["Rank", "Release Date", "Movie", "Production Budget", "Domestic Gross", "Worldwide Gross"]
        df = pd.DataFrame(all_movie_data, columns=columns)
        
        # Save the data to a CSV file
        df.to_csv('movie_budgets.csv', index=False)
        print("Scraping complete. Data saved to movie_budgets.csv.")
    else:
        print("No data was scraped.")

if __name__ == "__main__":
    main()