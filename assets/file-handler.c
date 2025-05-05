// https://github.com/gokcehan/lf/wiki/Integrations#d-bus

#include <stdio.h>
#include <stdlib.h>
#include <dbus/dbus.h>
#include <string.h>

static void show_items(DBusMessage* message) {
    // set TERMINAL to configure the terminal in which lf is opened
    const char *term = getenv("TERMINAL");
    DBusMessageIter iter;
    dbus_message_iter_init(message, &iter);
    DBusMessageIter array;
    dbus_message_iter_recurse(&iter, &array);

    while (dbus_message_iter_get_arg_type(&array) != DBUS_TYPE_INVALID) {
        const char* item;
        dbus_message_iter_get_basic(&array, &item);
        const char* path = item;
        // Handle 'file://' and 'file:/'
        if (strncmp(item, "file://", 7) == 0) {
            path = item + 7;
        } else if (strncmp(item, "file:/", 6) == 0) {
            path = item + 5;
        }
        char* cmd;
        asprintf(&cmd, "%s lf '%s' &", term, path);
        system(cmd);
        free(cmd);
        dbus_message_iter_next(&array);
    }
}

static DBusHandlerResult message_handler(DBusConnection* connection, DBusMessage* message, void* user_data) {
    if (dbus_message_is_method_call(message, "org.freedesktop.FileManager1", "ShowItems")) {
        DBusMessage* reply = dbus_message_new_method_return(message);
        if (reply != NULL) {
            show_items(message);
            dbus_connection_send(connection, reply, NULL);
            dbus_message_unref(reply);
        } else {
            fprintf(stderr, "Error creating reply message\n");
            return DBUS_HANDLER_RESULT_NOT_YET_HANDLED;
        }
    }

    return DBUS_HANDLER_RESULT_HANDLED;
}

int main() {
    DBusConnection* connection = dbus_bus_get(DBUS_BUS_SESSION, NULL);
    if (connection == NULL) {
        fprintf(stderr, "Failed to connect to the D-Bus session bus\n");
        return 1;
    }

    dbus_bus_request_name(connection, "org.freedesktop.FileManager1", DBUS_NAME_FLAG_REPLACE_EXISTING, NULL);

    dbus_connection_add_filter(connection, message_handler, NULL, NULL);
    while (dbus_connection_read_write_dispatch(connection, -1))
        ;

    return 0;
}
