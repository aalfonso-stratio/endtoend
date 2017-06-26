package com.stratio.endtoend.specs;

import com.stratio.qa.utils.ThreadProperty;
import cucumber.api.java.en.Then;

public class EndToEndSpec extends BaseSpec {

    public EndToEndSpec(Common spec) {
        this.commonspec = spec;
    }

    /*
     * Sanitize environment variable
     * @param envVar
     */
    @Then("^I sanitize environment variable '(.+?)'$")
    public void sanitizeEnvVar(String envVar) throws Exception {
        String var = ThreadProperty.get(envVar);
        String[] result = var.split("\r\n");
        for (int i = 0, size = result.length; i < size; i++) {
            if (! result[i].equalsIgnoreCase("bash")){
                var = result[i];
                break;
            }
        }

        ThreadProperty.set(envVar, var);
    }
}
