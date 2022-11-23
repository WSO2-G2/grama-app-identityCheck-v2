import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/http;
import ballerina/sql;

configurable int PORT = ?;
configurable string DB = ?;
configurable string PASSWORD = ?;
configurable string USER = ?;
configurable string HOST = ?;

type person record {
    int userId;
    string nic;
    string name;
};

# A service representing a network-accessible API
# bound to port `9090`.
# test
service / on new http:Listener(9090) {

    isolated resource function get checkId(string nic) returns json|error? {
        mysql:Client mysqlEp = check new (host = HOST, user = USER, password = PASSWORD, database = DB, port = PORT);

        person|error queryRowResponse = mysqlEp->queryRow(sqlQuery = `SELECT * FROM person WHERE nic = ${nic}`);

        error? e = mysqlEp.close();

        boolean result;

        if (e is error) {
            return e;
        }

        // return response;

        if (queryRowResponse is error) {
            result = false;
        }
        else {
            result = true;
        }

        json response = {
            statusCode: 200,
            headers: {
                "Access-Control-Allow-Headers": "application/json",
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
            },
            body: result.toJsonString()
        };
        return response;
    }

    resource function post addRecord(@http:Payload person payload) returns sql:ExecutionResult|error? {

        mysql:Client mysqlEp1 = check new (host = HOST, user = USER, password = PASSWORD, database = DB, port = PORT);

        sql:ExecutionResult executeResponse = check mysqlEp1->execute(sqlQuery = `INSERT INTO person(nic,name) VALUES (${payload.nic}, ${payload.name})`);
        error? e = mysqlEp1.close();
        if (e is error) {
            return e;
        }
        return executeResponse;
    }
    
    resource function get getdetails(string nic) returns person|error? {
        mysql:Client mysqlEp = check new (host = HOST, user = USER, password = PASSWORD, database = DB, port = PORT);

        person|error queryRowResponse = mysqlEp->queryRow(sqlQuery = `SELECT * FROM person WHERE nic = ${nic}`);
        error? e = mysqlEp.close();
        if (e is error) {
            return e;
        }
        return queryRowResponse;

    }
}
