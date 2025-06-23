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

      // Collect form data
      const formData = new FormData(form);
      const interests = [];
      form
        .querySelectorAll('input[name="interest[]"]:checked')
        .forEach((cb) => {
          interests.push(cb.value);
        });

      const { error } = await supabase.from("yuva_shakthi_members").insert([
        {
          user_id: session.user.id,
          fullname: formData.get("fullname"),
          parentname: formData.get("parentname"),
          dob: formData.get("dob"),
          gender: formData.get("gender"),
          phone: formData.get("phone"),
          email: formData.get("email"),
          address: formData.get("address"),
          village: formData.get("village"),
          mandal: formData.get("mandal"),
          constituency: formData.get("constituency"),
          district: formData.get("district"),
          education: formData.get("education"),
          stream: formData.get("stream"),
          occupation: formData.get("occupation"),
          skills: formData.get("skills"),
          interests,
          interest_other: formData.get("interest_other"),
          why: formData.get("why"),
        },
      ]);

      if (error) {
        alert("Submission failed: " + error.message);
      } else {
        alert("Your membership form has been submitted successfully!");
        form.reset();
      }
    });
  }
});
