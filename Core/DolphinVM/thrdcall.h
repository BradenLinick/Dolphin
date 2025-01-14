/******************************************************************************

	File: thrdcall.h

	Description:

	External threaded calls.

******************************************************************************/
#pragma once

#include "Ist.h"
#include "Interprt.h"

#ifdef _DEBUG
#define TRACING 1
#else
#define TRACING 0
#endif

template<class T> class SmartPtr
{
	T* m_pObj;

private:
	void AddRef()
	{
		if (m_pObj) 
			m_pObj->AddRef();
	}

	void Release()
	{
		if (m_pObj)
			m_pObj->Release();
	}

public:

	// Constructors
	SmartPtr() : m_pObj(0) {}

	SmartPtr(T* p, bool bAddRef=true) : m_pObj(p)
	{
		if (bAddRef)
			AddRef();
	}

	// Copy constructor
	SmartPtr(const SmartPtr& other) : m_pObj(other.m_pObj)
	{
		AddRef();
	}

	// Move constructor
	SmartPtr(SmartPtr&& other) : m_pObj(other.m_pObj)
	{
		other.m_pObj = nullptr;
	}

	// Destructor
	~SmartPtr()
	{
		Release();
	}

	// Assignments
	SmartPtr& operator=(T* p)
	{
		if (p)
			p->AddRef();
		Release();
		m_pObj = p;
		return *this;
	}

	SmartPtr& operator=(const SmartPtr& cp)
	{ 
		return operator=(cp.m_pObj); 
	}

	SmartPtr& operator=(SmartPtr&& other) 
	{
		if (this != &other) 
		{
			Release();
			m_pObj = other.m_pObj;
			other.m_pObj = nullptr;
		}
		return *this;
	}

	T* operator->() const
	{
		return m_pObj; 
	}

	T& operator*() const
	{
		_ASSERTE(m_pObj);
		// Will GPF if m_pObj is NULL
		return *m_pObj;
	}

	operator T*() const
	{
		return m_pObj;
	}
	
	operator bool() const
	{ 
		return m_pObj != NULL; 
	}
};

class OverlappedCall;
typedef SmartPtr<OverlappedCall> OverlappedCallPtr;

class OverlappedCall
{
public:
	// Allocate/free methods for maintaining pool of available blocks
	bool QueueTerminate();
	bool QueueSuspend();
	DWORD Resume();

	friend std::wostream& operator<<(std::wostream& stream, const OverlappedCall& oc);

	DWORD AddRef();
	DWORD Release();

	enum States { Starting, Resting, Terminated, Calling, Returned };

	States beTerminated();

private:
	///////////////////////////////////////////////////////////////////////////
	// Private member functions

	OverlappedCall(ProcessOTE*);
	~OverlappedCall();

	Process* GetProcess() 
	{ 
		HARDASSERT((POTE)m_oteProcess != Pointers.Nil);
		return m_oteProcess->m_location; 
	}

	// Start corresponding OS thread
	bool BeginThread();

	void Init();
	void Term();
	void Free();

	void TerminateThread();

	bool Initiate(CompiledMethod* pMethod, unsigned nArgCount);
	DWORD WaitForRequest();
	int ProcessRequests();
	bool PerformCall();
	bool CallFinished();

	int Main();
	int TryMain();

	// Called from assembler
	void /*thiscall*/ OnCallReturned();
	bool CanComplete();
	void NotifyInterpreterOfCallReturn();

	// Allows thread to suspend itself 
	void SuspendThread();
	DWORD ResumeThread();

	// Queue a notification to the interpreter thread that an overlapped thread
	// has received a termination signal
	bool NotifyInterpreterOfTermination();
	void WaitForInterpreter();

	void RemoveFromPendingTerminations();

	bool QueueForInterpreter(PAPCFUNC pfnAPC);
	bool QueueForMe(PAPCFUNC pfnAPC);

public:
	///////////////////////////////////////////////////////////////////////////
	// Static member functions

	static void Initialize();
	static void Uninitialize();

	static OverlappedCallPtr GetActiveProcessOverlappedCall();
	static OverlappedCallPtr Do(CompiledMethod* pMethod, unsigned argCount);

	static Semaphore* pendingTerms();

	void OnActivateProcess();
	void OnCompact();

	bool IsInCall();

private:
	// Low-level management routines
	static OverlappedCallPtr New(ProcessOTE*);
	//static OverlappedCallPtr RemoveFirstFromList(OverlappedCallList&);

	// Thread entry point function
	static unsigned __stdcall ThreadMain(void* pThis);
	static int MainExceptionFilter(LPEXCEPTION_POINTERS pExInfo);

	// APC functions (APCs are used to queue messages between threads)
	static void __stdcall SuspendAPC(DWORD dwParam);
	static void __stdcall TerminatedAPC(DWORD dwParam);
	static OverlappedCallPtr BeginAPC(DWORD dwParam);
	static OverlappedCallPtr BeginMainThreadAPC(DWORD dwParam);

	//static void CompactCallsOnList(OverlappedCallList& list);

	///////////////////////////////////////////////////////////////////////////
	// Static data members
private:

	//static OverlappedCallList s_activeList;
	
	static bool s_bShutdown;

	///////////////////////////////////////////////////////////////////////////
	// Data members
public:
	#if TRACING == 1
		tracestream thinDump;
	#endif

	// Context of the process for which we are running
	InterpreterRegisters	m_interpContext;
	ProcessOTE*				m_oteProcess;	// paired Smalltalk Process
	SHAREDLONG				m_dwRefs;

	HANDLE					m_hThread;		// thread handle (returned by _beginthread(ex))
	DWORD					m_dwThreadId;	// thread's ID
	HANDLE					m_hEvtGo;		// Set when ready to initiate a call (auto-reset)
	HANDLE					m_hEvtCompleted;// Set when call has completed (auto-reset)

	// Method causing this overlapped call to start executing
	CompiledMethod*			m_pMethod;
	unsigned				m_nArgCount;
	volatile States			m_state;
private:
	SHAREDLONG				m_nSuspendCount;
	_PrimitiveFailureCode	m_primitiveFailureCode;
};


std::wostream& operator<<(std::wostream& stream, const OverlappedCall& oc);

inline DWORD OverlappedCall::AddRef()
{
	return InterlockedIncrement(&m_dwRefs);
}

inline DWORD OverlappedCall::Release()
{
	DWORD dwRefs = InterlockedDecrement(&m_dwRefs);
	if (dwRefs == 0)
		delete this;
	return dwRefs;
}

inline bool OverlappedCall::IsInCall()
{
	HARDASSERT(::GetCurrentThreadId() == Interpreter::MainThreadId());
	return m_state >= Calling;
}
