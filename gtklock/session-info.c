#include <gtk/gtk.h>
#include <string.h>

#include "gtklock-module.h"

#define MODULE_DATA(window) ((window)->module_data[self_id])
#define LANGUAGE_LABEL(window) ((GtkWidget *)MODULE_DATA(window))

const gchar module_name[] = "session-info";
const guint module_major_version = 2;
const guint module_minor_version = 1;
GOptionEntry module_entries[] = {{NULL}};

static int self_id;

static gchar *active_layout(void) {
	gchar *argv[] = {"swaymsg", "-t", "get_inputs", "-r", NULL};
	gchar *output = NULL;
	gint status = 0;
	GError *error = NULL;

	if (!g_spawn_sync(NULL, argv, NULL, G_SPAWN_SEARCH_PATH, NULL, NULL,
			&output, NULL, &status, &error) || status != 0) {
		g_clear_error(&error);
		g_free(output);
		return g_strdup("Unknown");
	}

	const gchar marker[] = "\"xkb_active_layout_name\": \"";
	gchar *start = strstr(output, marker);
	if (start == NULL) {
		g_free(output);
		return g_strdup("Unknown");
	}

	start += strlen(marker);
	gchar *end = strchr(start, '"');
	if (end == NULL) {
		g_free(output);
		return g_strdup("Unknown");
	}

	gchar *layout = g_strndup(start, end - start);
	g_free(output);

	if (g_str_has_prefix(layout, "English")) {
		g_free(layout);
		return g_strdup("EN");
	}
	if (g_str_has_prefix(layout, "Russian")) {
		g_free(layout);
		return g_strdup("RU");
	}
	return layout;
}

static void update_window_label(struct Window *window, const gchar *layout) {
	if (LANGUAGE_LABEL(window) == NULL) {
		return;
	}

	gchar *label = g_strdup_printf("LANG: %s", layout);
	gtk_label_set_text(GTK_LABEL(LANGUAGE_LABEL(window)), label);
	g_free(label);
}

static gboolean update_labels(gpointer data) {
	struct GtkLock *gtklock = data;
	gchar *layout = active_layout();

	for (guint i = 0; i < gtklock->windows->len; i++) {
		struct Window *window = g_array_index(gtklock->windows, struct Window *, i);
		update_window_label(window, layout);
	}

	g_free(layout);
	return G_SOURCE_CONTINUE;
}

static void show_password_form_on_all_outputs(struct GtkLock *gtklock) {
	for (guint i = 0; i < gtklock->windows->len; i++) {
		struct Window *window = g_array_index(gtklock->windows, struct Window *, i);
		gtk_revealer_set_reveal_child(GTK_REVEALER(window->body_revealer), TRUE);
	}
}

void on_activation(struct GtkLock *gtklock, int id) {
	self_id = id;
	g_timeout_add_seconds(1, update_labels, gtklock);
}

void on_focus_change(struct GtkLock *gtklock, struct Window *window, struct Window *old_window) {
	(void)window;
	(void)old_window;
	show_password_form_on_all_outputs(gtklock);
}

void on_window_create(struct GtkLock *gtklock, struct Window *window) {
	(void)gtklock;
	gtk_widget_set_halign(window->body_grid, GTK_ALIGN_CENTER);
	gtk_widget_set_halign(window->input_field, GTK_ALIGN_CENTER);
	gtk_widget_set_hexpand(window->input_field, FALSE);

	GtkWidget *language_label = gtk_label_new("LANG: ...");
	gtk_widget_set_name(language_label, "language");
	gtk_widget_set_halign(language_label, GTK_ALIGN_CENTER);
	gtk_container_add(GTK_CONTAINER(window->window_box), language_label);
	gtk_box_reorder_child(GTK_BOX(window->window_box), language_label, 2);
	MODULE_DATA(window) = language_label;

	gtk_widget_set_no_show_all(window->input_label, TRUE);
	gtk_widget_hide(window->input_label);
	gtk_widget_set_no_show_all(window->unlock_button, TRUE);
	gtk_widget_hide(window->unlock_button);

	gchar *layout = active_layout();
	update_window_label(window, layout);
	g_free(layout);
}
