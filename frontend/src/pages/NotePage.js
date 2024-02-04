import React, { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { ReactComponent as ArrowLeft } from "../assets/arrow-left.svg";

const NotePage = () => {
  const { id } = useParams();
  const [note, setNote] = useState(null);
  const navigate = useNavigate();

  useEffect(() => {
    const getNote = async () => {
      try {
        if (id === 'new') return
        let response = await fetch(`/api/notes/${id}`);
        let data = await response.json();
        setNote(data);
      } catch (error) {
        console.error("Error fetching note:", error);
      }
    };

    getNote();
  }, [id]);

  let updateNote = async () => {
    fetch(`/api/notes/${id}/update/`, {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(note),
    });
  };

  let createNote = async () => {
    fetch(`/api/notes/create/`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(note),
    });
  };

  let deleteNote = async () => {
    fetch(`/api/notes/${id}/delete/`, {
      method: 'DELETE',
      headers: {
        "Content-Type": "application/json",
      }
    })
    navigate("/");
    
  }

  let handleSubmit = () => {
    if (id !== 'new') {
      if (note && note.body === '') {
        deleteNote();
      } else {
        updateNote();
      }
    } else if (id === 'new' && note && note.body !== null) {
      createNote();
    }
    navigate("/");
  };

  let handleChange = (value) => {
    setNote(note => ({...note, 'body':value}))
  }

  return (
    <div className="note">
      <div className="note-header">
        <h3>
          <ArrowLeft onClick={handleSubmit} />
        </h3>
        {id !== 'new' ? (
          <button onClick={deleteNote}>Delete</button>
        ): (
          <button onClick={handleSubmit}>Done</button>
        )}
        
      </div>
      <textarea
        onChange={(e) => {
          handleChange(e.target.value)
        }}
        value={note?.body}
      ></textarea>
    </div>
  );
};

export default NotePage;
