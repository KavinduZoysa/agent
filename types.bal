import ballerina/time;
type Person record {|
    string firstName;
    string lastName;
	Address address;
    Birth birth;
|};

type Address record {|
	string street;
	string city;
	string country;
|};

type Birth record {|
	string year;
	string month;
	string date;
|};

type Profile record {|
	string name;
	string address;
	string birthDay;
|};

type Name record {|
	string firstName;
	string lastName;
|};


public function foo() returns time:Error? {
	time:Civil civilFromEmailString = check time:civilFromEmailString("10 Oct 2021");
}

