class Flight:
    def __init__(self, flight_number, departure_city, arrival_city, departure_time, passenger_list, seat_capacity=150):
        self.flight_number = flight_number
        self.departure_city = departure_city
        self.arrival_city = arrival_city
        self.departure_time = departure_time
        self.passenger_list = []
        self.seat_capacity = seat_capacity

    def add_passenger(self, passenger):
        if(len(self.passenger_list) < self.seat_capacity):
            self.passenger_list.append(passenger)
        else:
            print("Sorry this flight is full!")

    def remove_passenger(self, passenger):
        try:
            self.passenger_list.remove(passenger)
        except ValueError:
            print(f"{passenger} is not on this flight!")

    def log_flight(self):
        with open(file = "./flight_log.txt", mode = 'at', encoding='utf-8') as f:
            f.write(str(self.flight_number) +", " + str(self.departure_city) +", " + str(self.arrival_city) +", " + str(len(self.passenger_list)) + "\n")

    def check_availability(self):
        return self.seat_capacity - len(self.passenger_list)
    
    def __str__(self):
        return f"Flight {self.flight_number} from {self.departure_city} to {self.arrival_city}"