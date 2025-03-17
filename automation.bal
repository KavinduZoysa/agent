// import ballerina/io;
import ballerina/log;
import ballerina/os;
import ballerinax/ai.agent;
import ballerinax/googleapis.calendar;
import ballerinax/googleapis.gmail;

configurable string googleRefreshToken = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshUrl = ?;

configurable string apiKey = ?;
configurable string deploymentId = ?;
configurable string apiVersion = ?;
configurable string serviceUrl = ?;

configurable string userName = ?;

final gmail:Client gmail = check new gmail:Client(config = {
    auth: {refreshToken: googleRefreshToken, clientId, clientSecret, refreshUrl}
});

final calendar:Client calendarClient = check new (config = {
    auth: {clientId, clientSecret, refreshToken: googleRefreshToken, refreshUrl}
});

@agent:Tool
@display {
    label: "",
    iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.gmail_4.0.1.png"
}
isolated function readEmails() returns gmail:Message[]|error {
    gmail:ListMessagesResponse messageList = check gmail->/users/me/messages(q = "label:INBOX is:unread");
    gmail:Message[] messages = messageList.messages ?: [];
    gmail:Message[] completeMessages = [];
    foreach gmail:Message message in messages {
        gmail:Message completeMsg = check gmail->/users/me/messages/[message.id](format = "full");
        completeMessages.push(completeMsg);
    }
    return completeMessages;
}

@agent:Tool
@display {
    label: "",
    iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.gmail_4.0.1.png"
}
isolated function sendEmail(string[] to, string subject, string body) returns gmail:Message|error {
    gmail:MessageRequest requestMessage = {to, subject, bodyInText: body};
    gmail:Message message = check gmail->/users/me/messages/send.post(requestMessage);
    return gmail->/users/me/messages/[message.id]/modify.post({removeLabelIds: ["UNREAD"]}); // Mark as read
}

@agent:Tool
@display {
    label: "",
    iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.calendar_3.2.1.png"
}
isolated function getCalanderEvents() returns calendar:Event[]|error {
    stream<calendar:Event, error?> eventStream = check calendarClient->getEvents("mahroofsabthar@gmail.com");
    calendar:Event[] events = check from var event in eventStream
        select event;
    return events;
}

@agent:Tool
@display {
    label: "",
    iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.calendar_3.2.1.png"
}
isolated function createCalanderEvent(calendar:InputEvent event) returns calendar:Event|error {
    return calendarClient->createEvent("mahroofsabthar@gmail.com", event);
}

@agent:Tool
isolated function getCurrentDate() returns string|error {
    os:Command command = {value: "date", arguments: ["-u", "+'%Y-%m-%dT%H:%M:%S%:z'"]};
    os:Process process = check os:exec(command);
    byte[] output = check process.output();
    return string:fromBytes(output);
}

final string instructions = string `You are Nova, an intelligent personal AI assistant designed to help '${userName}' stay organized and efficient.
Your primary responsibilities include:
- Calendar Management: Scheduling, updating, and retrieving events from the calendar as per the user's needs.
- Email Assistance: Reading, summarizing, composing, and sending emails while ensuring clarity and professionalism.
- Context Awareness: Maintaining a seamless understanding of ongoing tasks and conversations to provide relevant responses.
- Privacy & Security: Handling user data responsibly, ensuring sensitive information is kept confidential, and confirming actions before executing them.
Guidelines:
- Respond in a natural, friendly, and professional tone.
- Always confirm before making changes to the user's calendar or sending emails.
- Provide concise summaries when retrieving information unless the user requests details.
- Prioritize clarity, efficiency, and user convenience in all tasks.`;

final agent:SystemPrompt systemPrompt = {
    role: "Personal AI Assistant",
    instructions
};
final agent:AzureOpenAiModel model = check new agent:AzureOpenAiModel(serviceUrl, apiKey, deploymentId, apiVersion);
final agent:Agent personalAssistant = check new (
    systemPrompt = {
        role: "Personal AI Assistant",
        instructions: string `You are Nova, an intelligent personal AI assistant designed to help '${userName}' stay organized and efficient.
Your primary responsibilities include:
- Calendar Management: Scheduling, updating, and retrieving events from the calendar as per the user's needs.
- Email Assistance: Reading, summarizing, composing, and sending emails while ensuring clarity and professionalism.
- Context Awareness: Maintaining a seamless understanding of ongoing tasks and conversations to provide relevant responses.
- Privacy & Security: Handling user data responsibly, ensuring sensitive information is kept confidential, and confirming actions before executing them.
Guidelines:
- Respond in a natural, friendly, and professional tone.
- Always confirm before making changes to the user's calendar or sending emails.
- Provide concise summaries when retrieving information unless the user requests details.
- Prioritize clarity, efficiency, and user convenience in all tasks.`
    },
    model = model,
    tools = [readEmails, sendEmail, createCalanderEvent, getCalanderEvents, getCurrentDate],
    verbose = true
);

public function main() returns error? {
    do {
        gmail:ListDraftsResponse gmailListdraftsresponse = check gmail->/users/[""]/drafts.get();
        string response = check personalAssistant->run("Please provide the subjects of all unread messages");
        log:printInfo(response);
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}

// public function main() returns error? {
//     do {
//         Address address = {country: "", city: "", street: ""};
//         Name name = {firstName: "", lastName: ""};

//         // Person person = check getHistoricalPerson(1917, "John");
//         // io:println(person.firstName + " " + person.lastName);
//     } on fail error e {
//         log:printError("Error occurred", 'error = e);
//         return e;
//     }
// }
