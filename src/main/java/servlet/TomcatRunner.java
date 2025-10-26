package servlet;

import java.io.File;

import org.apache.catalina.startup.Tomcat;
import org.apache.catalina.connector.Connector;

/**
 * 組み込みTomcat起動クラス /webapp (または /webapp/webapp / src/main/webapp) をルートにし、 0.0.0.0 にバインドして Render の
 * PORT を利用する
 */
public class TomcatRunner {

    public static void main(String[] args) throws Exception {
        String portEnv = System.getenv("PORT");
        int port;
        try {
            port = (portEnv != null && !portEnv.isBlank()) ? Integer.parseInt(portEnv) : 8080;
        } catch (NumberFormatException e) {
            port = 8080;
        }

        Tomcat tomcat = new Tomcat();

        Connector connector = new Connector();
        connector.setScheme("http");
        connector.setPort(port);
        connector.setProperty("address", "0.0.0.0");
        tomcat.getService().addConnector(connector);
        tomcat.setConnector(connector);

        String webappDirLocation;
        if (new File("/webapp/index.jsp").exists()) {
            webappDirLocation = new File("/webapp").getAbsolutePath();
        } else if (new File("/webapp/webapp/index.jsp").exists()) {
            webappDirLocation = new File("/webapp/webapp").getAbsolutePath();
        } else if (new File("src/main/webapp").exists()) {
            webappDirLocation = new File("src/main/webapp").getAbsolutePath();
        } else {
            webappDirLocation = new File(".").getAbsolutePath();
        }

        System.out.println("Using webapp directory: " + webappDirLocation);
        tomcat.addWebapp("", webappDirLocation);

        System.out.println("Starting Tomcat on port: " + port);
        tomcat.start();
        tomcat.getServer().await();
    }
}
