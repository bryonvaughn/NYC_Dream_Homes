## Problem Statement

The team has been provided the following project scope statement:

> Dream Homes NYC is a real estate agency servicing the Tri-State area (NY, NJ, CT), with multiple office locations in each state. They connect home sellers with potential buyers and home owners with potential renters. In other words, Dream Homes NYC clients can buy, rent, or sell homes (note: homes means single houses, townhouses, apartments, etc). The company employs both full-time and part-time agents. Dream Homes NYC wants to modernize their systems and build a database that will help them both organize their corporate data (offices, employees, expenses, profits, etc) and more importantly save all information on homes, clients, transactions, open houses, appointments, and anything else that can make them more efficient while improving the client experience.  Your team is hired to develop this new system. Dream Homes NYC leadership is even thinking about using the database to drive insights and perhaps build an app in the future.

Given the client’s initial direction, and a deep dive into the existing business processes, we will design a solution focused on the following set of business requirements:

### Functional Requirements
  - ***Client and Property Management***
    - *Client Information*
      - Details including contact information, preferences (type of dwelling, location, etc.), and transaction history.
        - This includes buyers, sellers, renters.
    - *Property Listings*
        - Details of all properties (single houses, townhouses, apartments) including location, size, price, and current status (available, sold, rented).
    - *Transactions*
        - Details for all transactions (buying, selling, renting) including date, involved parties, property, price, commission.
            - Consider multiple listings for single properties (history)
            - Consider phases of transactions (pending, sold, etc.)
  - ***Operational Efficiency***
    - *Events (Open Houses and Appointments)*
        - Schedule and track open houses and client appointments, including agent assignments and client attendance.
    - *Communications*
        - History of all communications with clients, including emails, phone calls, and messages.
  - ***Business Data Management***
      - *Office Locations*
        - Details of all office locations including address, contact information, and office manager.
      - *Employees (Agents)*
        - Maintain records of both full-time and part-time agents, including personal details, employment status, roles, and performance metrics.
      - *Financial Data*
        - Track company expenses, profits, and other financial metrics for each office and overall company performance.
  - ***Insights and Analytics***
    - *Reporting*
      - Generate various reports (financial, operational, client-related) to help management make informed decisions.
    - *Analytics*
      - Dashboards to identify market trends, agent performance, and client preferences.

### Non-Functional Requirements

Other than ensuring a scalable data solution, the following technical requirements are not within the initial scope of the database design project. This does not mean they are not important, and should be considered essential for the final go live scenario, especially before replacing existing systems and business processes.

  - ***Performance***
    - *Scalability*
      - Ensure the database can scale to accommodate the growing data from multiple office locations and increasing number of transactions.
    - *Security*
      - Implement robust security measures to protect sensitive client and corporate data.
    - *Compliance*
      - Ensure the database complies with real estate regulations and data protection laws.
  - ***Infrastructure***
    - *Cloud Storage*
      - Utilize cloud storage solutions for scalability, reliability, and remote access. This will be critical for plans for future mobile app development.
    - *Data Backup*
      - Implement regular data backup procedures to prevent data loss.
