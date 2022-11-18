import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/http;
import ballerina/sql;

type person record {
    int userId;
    string nic;
    string name;
};

# A service representing a network-accessible API
# bound to port `9090`.
# test
service / on new http:Listener(9090) {

    isolated resource function get checkId(string nic) returns boolean|error? {
        mysql:Client mysqlEp = check new (host = "workzone.c6yaihe9lzwl.us-west-2.rds.amazonaws.com", user = "admin", password = "Malithi1234", database = "gramaIdentityCheck", port = 3306);

        person|error queryRowResponse = mysqlEp->queryRow(sqlQuery = `SELECT * FROM person WHERE nic = ${nic}`);

        error? e = mysqlEp.close();

        if (e is error) {
            return e;
        }

        if (queryRowResponse is error) {
            return false;
        }
        else {
            return true;
        }
    }

    resource function post addRecord(@http:Payload person payload) returns sql:ExecutionResult|error? {

        mysql:Client mysqlEp1 = check new (host = "workzone.c6yaihe9lzwl.us-west-2.rds.amazonaws.com", user = "admin", password = "Malithi1234", database = "gramaIdentityCheck", port = 3306);
        
        sql:ExecutionResult executeResponse = check mysqlEp1->execute(sqlQuery = `INSERT INTO person(nic,name) VALUES (${payload.nic}, ${payload.name})`);
        error? e = mysqlEp1.close();
        if (e is error) {
            return e;
        }
        return executeResponse;
    }
}
