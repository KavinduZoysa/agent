import ballerinax/np;

isolated function foo1(string s) returns string {
    return s;
}

public isolated function foo2(string s) returns string {
    return s;
}

public isolated function foo3(string s) returns string {
    return s;
}

public isolated function getHistoricalPerson(
    int year,
    string nameSegment,
    np:Prompt prompt = `Find the best matching historical person who was born in ${year} and
                        has ${nameSegment} as one of their names`) returns Person|error = @np:NaturalFunction external;
                        
function naturalFunction(np:Prompt prompt = `sdsdsdsd`) returns string|error = @np:NaturalFunction external;

