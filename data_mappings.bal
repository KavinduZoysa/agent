function transform(Person person) returns Profile => {
    name: string:'join(" ", person.firstName, person.lastName),
    address: string:'join(",", person.address.street, person.address.city, person.address.country),
    birthDay: string:'join(":", person.birth.year, person.birth.month, person.birth.date)
};
