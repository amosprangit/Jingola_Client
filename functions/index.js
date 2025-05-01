const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.getOrders = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated to place orders",
    );
  }

  try {
    // Verify the calling user matches the order user
    if (context.auth.uid !== data.userId) {
      throw new functions.https.HttpsError(
          "permission-denied",
          "User can only place orders for themselves",
      );
    }

    // Create order document
    const orderRef = await admin
        .firestore()
        .collection("orders")
        .add({
          date: `${new Date().getDate()}-${
            new Date().getMonth() + 1
          }-${new Date().getFullYear()}`,
          items: data.items,
          location: data.location,
          deliveryDate: data.deliveryDate,
          deliveryTime: data.deliveryTime,
          status: "Pending",
          total: data.total,
          userId: data.userId,
          time: admin.firestore.FieldValue.serverTimestamp(),
          orderTime: data.orderTime,
        });

    return {
      success: true,
      orderId: orderRef.id,
      message: "Order placed successfully",
    };
  } catch (error) {
    console.error("Error placing order:", error);
    throw new functions.https.HttpsError(
        "internal",
        "Failed to place order",
        error.message,
    );
  }
});
