import ballerina/http;
import ballerinax/ai.agent;

listener http:Listener httpDefaultListener = http:getDefaultListener();

listener agent:Listener agent1Listener = new (listenOn = check http:getDefaultListener());

service /agent1 on agent1Listener {
    resource function post chat(@http:Payload agent:ChatReqMessage request) returns agent:ChatRespMessage|error {

        string stringResult = check _agent1Agent->run(request.message);
        return {message: stringResult};
    }
}

service /history on httpDefaultListener {
    resource function get profile(Name name, Address address) returns error|json|http:InternalServerError {
        do {
            // Profile profile = transform(person);
            // return profile;

            Person person = {address: {street: address.street, city: address.city, country: address.country}, firstName: name.firstName, lastName: name.lastName, birth: {year: "", month: "", date: ""}};
            return person;
        } on fail error err {
            // handle error
            return error("Not implemented", err);
        }
    }
}
