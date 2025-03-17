import ballerinax/ai.agent;

final agent:OpenAiModel _agent1Model = check new ("", "gpt-3.5-turbo-16k-0613");
final agent:Agent _agent1Agent = check new (
    systemPrompt = {
        role: "",
        instructions: string ``
    }, model = _agent1Model, tools = [foo1T, foo2T, foo3T]
);

@agent:Tool
@display {label: "", iconPath: ""}
isolated function foo1T(string s) returns string {
    string result = foo1(s);
    return result;
}

@agent:Tool
@display {label: "", iconPath: ""}
isolated function foo2T(string s) returns string {
    string result = foo2(s);
    return result;
}

@agent:Tool
@display {label: "", iconPath: ""}
isolated function foo3T(string s) returns string {
    string result = foo3(s);
    return result;
}

final agent:OpenAiModel agentOpenaimodel = check new ("", "gpt-3.5-turbo-16k-0613");
final agent:Agent agentAgent = check new (
    systemPrompt = {role: "ROLE", instructions: string `Instructions`}, model = agentOpenaimodel, tools = []
);
