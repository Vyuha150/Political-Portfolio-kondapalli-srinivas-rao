import { supabase } from "./supabaseClient.js";

document.addEventListener("DOMContentLoaded", async () => {
  // Check if user is signed in
  const {
    data: { session },
  } = await supabase.auth.getSession();
  if (!session) {
    alert("You must be signed in to submit this form.");
    window.location.href = "signin.html";
    return;
  }

  const form = document.querySelector(".form-container form");
  if (form) {
    form.addEventListener("submit", async (e) => {
      e.preventDefault();

      const formData = new FormData(form);

      const { error } = await supabase.from("volunteers").insert([
        {
          user_id: session.user.id,
          name: formData.get("name"),
          email: formData.get("email"),
          phone: formData.get("phone"),
          constituency: formData.get("constituency"),
          message: formData.get("message"),
        },
      ]);

      if (error) {
        alert("Submission failed: " + (error.message || JSON.stringify(error)));
        console.error(error);
      } else {
        alert("Thank you for joining as a volunteer!");
        form.reset();
      }
    });
  }
});
