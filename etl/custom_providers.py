# configure custom providers for faker package for more specific data
from faker.providers import BaseProvider

class NYCAddressProvider(BaseProvider):
    def nyc_address(self):
        streets = [
            '1st Ave', '2nd Ave', '3rd Ave', '4th Ave', '5th Ave',
            'Broadway', 'Madison Ave', 'Park Ave', 'Lexington Ave',
            'Wall Street', 'Fulton Street', 'Canal Street', 'Bowery',
            'Houston Street', 'Bleecker Street', 'Mulberry Street', 'West End Ave',
            'Amsterdam Ave', 'Columbus Ave', 'Central Park West', 'Queens Blvd',
            'Astoria Blvd', 'Northern Blvd', 'Steinway Street', 'Roosevelt Ave',
            'Grand Concourse', 'Fordham Road', 'Jerome Ave', 'Arthur Ave',
            'Hylan Blvd', 'Richmond Ave', 'Forest Ave', 'Victory Blvd'
        ]
        neighborhoods = [
            'Manhattan', 'Brooklyn', 'Queens', 'Bronx', 'Staten Island'
        ]
        street_address = f"{self.generator.building_number()} {self.random_element(streets)}"
        city = "New York"
        state = "NY"
        zipcode = self.generator.extended_zipcode()
        neighborhood = self.random_element(neighborhoods)
        return {
            'address': street_address,
            'city': city,
            'state': state,
            'zipcode': zipcode,
            'neighborhood': neighborhood
        }

class NYCPersonProvider(BaseProvider):
    first_names = [
        'John', 'Jane', 'Michael', 'Emily', 'Chris', 'Jessica', 'Matthew', 'Ashley', 'David', 'Sarah',
        'Daniel', 'Amanda', 'Joshua', 'Brittany', 'Andrew', 'Megan', 'James', 'Lauren', 'Robert', 'Rachel',
        'Joseph', 'Hannah', 'Justin', 'Nicole', 'Ryan', 'Samantha', 'Brian', 'Heather', 'Brandon', 'Melissa',
        'Jason', 'Michelle', 'Tyler', 'Amber', 'Kevin', 'Amy', 'Eric', 'Rebecca', 'Steven', 'Laura',
        'Thomas', 'Kimberly', 'Aaron', 'Stephanie', 'Timothy', 'Crystal', 'Adam', 'Emma', 'Anthony', 'Olivia',
        'Charles', 'Chloe', 'Patrick', 'Sophia', 'Nathan', 'Isabella', 'Zachary', 'Mia', 'Jacob', 'Avery',
        'Jonathan', 'Evelyn', 'Benjamin', 'Grace', 'Nicholas', 'Lily', 'Alexander', 'Harper', 'Mason', 'Ellie',
        'Ethan', 'Abigail', 'Elijah', 'Charlotte', 'Caleb', 'Aria', 'Gabriel', 'Scarlett', 'Samuel', 'Victoria',
        'Cameron', 'Madison', 'Jackson', 'Layla', 'Logan', 'Penelope', 'Lucas', 'Aubrey', 'Dylan', 'Nora',
        'Evan', 'Zoey', 'Jack', 'Lillian', 'Isaac', 'Paisley', 'Jordan', 'Aurora', 'Connor', 'Addison'
    ]

    last_names = [
        'Smith', 'Johnson', 'Williams', 'Jones', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor',
        'Anderson', 'Thomas', 'Jackson', 'White', 'Harris', 'Martin', 'Thompson', 'Garcia', 'Martinez', 'Robinson',
        'Clark', 'Rodriguez', 'Lewis', 'Lee', 'Walker', 'Hall', 'Allen', 'Young', 'Hernandez', 'King',
        'Wright', 'Lopez', 'Hill', 'Scott', 'Green', 'Adams', 'Baker', 'Gonzalez', 'Nelson', 'Carter',
        'Mitchell', 'Perez', 'Roberts', 'Turner', 'Phillips', 'Campbell', 'Parker', 'Evans', 'Edwards', 'Collins',
        'Stewart', 'Sanchez', 'Morris', 'Rogers', 'Reed', 'Cook', 'Morgan', 'Bell', 'Murphy', 'Bailey',
        'Rivera', 'Cooper', 'Richardson', 'Cox', 'Howard', 'Ward', 'Torres', 'Peterson', 'Gray', 'Ramirez',
        'James', 'Watson', 'Brooks', 'Kelly', 'Sanders', 'Price', 'Bennett', 'Wood', 'Barnes', 'Ross',
        'Henderson', 'Coleman', 'Jenkins', 'Perry', 'Powell', 'Long', 'Patterson', 'Hughes', 'Flores', 'Washington',
        'Butler', 'Simmons', 'Foster', 'Gonzales', 'Bryant', 'Alexander', 'Russell', 'Griffin', 'Diaz', 'Hayes'
    ]
        
    def nyc_person(self, used_names):
        while True:
            first_name = self.random_element(self.first_names)
            last_name = self.random_element(self.last_names)
            full_name = f"{first_name} {last_name}"
            if full_name not in used_names:
                used_names.add(full_name)       
                email = f"{first_name.lower()}.{last_name.lower()}@example.com"
                phone_number = self.generator.phone_number()
                return {
                    'name': full_name,
                    'email': email,
                    'phone_number': phone_number
                }
    
class RentalDescriptionProvider(BaseProvider):
    def rental_description(self):
        adjectives = [
            'spacious', 'cozy', 'luxurious', 'modern', 'charming', 'beautiful', 'updated', 'gorgeous', 
            'sunny', 'bright', 'comfortable', 'elegant', 'welcoming', 'stylish', 'tranquil', 'serene', 
            'vibrant', 'peaceful', 'convenient', 'well-maintained'
        ]
        property_types = [
            'apartment', 'condo', 'villa', 'studio', 'townhouse'
        ]
        features = [
            'with a modern kitchen', 'with hardwood floors', 'with ample storage space', 'with a private balcony', 
            'with a spacious living room', 'with large windows', 'with an updated bathroom', 
            'with a cozy fireplace', 'with central air conditioning', 'with a beautiful garden'
        ]
        locations = [
            'in a quiet neighborhood', 'near public transportation', 'close to shopping and dining', 
            'in a family-friendly community', 'with easy access to parks', 'in a vibrant area', 
            'near excellent schools', 'with stunning views', 'close to the city center', 'in a gated community'
        ]
        
        description = f"This is a {self.random_element(adjectives)} {self.random_element(property_types)} {self.random_element(features)} located {self.random_element(locations)}."
        return description

class PropertyAmenitiesProvider(BaseProvider):
    def property_amenities(self):
        amenities_list = [
            "swimming pool", "gym", "laundry room", "parking garage", "24-hour security", "roof terrace",
            "garden", "playground", "pet-friendly", "elevator", "air conditioning", "high-speed internet",
            "on-site management", "BBQ area", "sauna", "jacuzzi", "storage units", "bike storage", "concierge service",
            "clubhouse", "business center", "package service", "valet parking", "wheelchair accessible"
        ]
        selected_amenities = self.random_elements(amenities_list, unique=True)
        return ", ".join(selected_amenities)

class ExtendedZipcodeProvider(BaseProvider):
    def extended_zipcode(self):
        base_zip = str(self.random_int(10000, 99999))
        extension = str(self.random_int(1000, 9999))
        return f"{base_zip}-{extension}"